require 'rails_helper'

RSpec.describe Activity, type: :model do
  subject(:activity) { FactoryBot.build_stubbed(:activity) }

  describe '#valid' do
    it { expect(activity).to be_valid }

    context 'when without a title' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, title: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without a price list' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, price_list: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without a start time' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, start_time: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without an end time' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, end_time: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without a created by' do
      subject(:activity) { FactoryBot.build_stubbed(:activity, created_by: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when start time is after end time' do
      subject(:activity) do
        FactoryBot.build_stubbed(:activity,
                                 start_time: Time.zone.now + 1.second,
                                 end_time: Time.zone.now)
      end

      it { expect(activity).not_to be_valid }
    end
  end

  describe 'cannot alter an activity after two months' do
    before { activity.title = "#{activity.title}_new" }

    context 'when within two months' do
      subject(:activity) { FactoryBot.build(:activity) }

      it { expect(activity).to be_valid }
    end

    context 'when after two months' do
      subject(:activity) { FactoryBot.build(:activity, :locked) }

      it { expect(activity).not_to be_valid }
    end
  end

  describe '#lock_date' do
    let(:start_time) { (2.months + 3.days).ago }

    subject(:activity) { FactoryBot.build(:activity, start_time: start_time, end_time: start_time + 4.hours) }

    it { expect(activity.lock_date).to eq activity.end_time + 2.months }
    it { expect(activity.locked?).to be true }

    context 'when with recent activity' do
      subject(:activity) { FactoryBot.build(:activity) }

      it { expect(activity.locked?).to be false }
    end
  end

  describe '.upcoming' do
    let(:past_activity) do
      FactoryBot.create(:activity, start_time: 2.days.ago, end_time: 1.day.ago)
    end

    subject(:future_activity) do
      FactoryBot.create(:activity, start_time: 1.day.from_now, end_time: 2.days.from_now)
    end

    it { expect(Activity.upcoming).to include future_activity }
    it { expect(Activity.upcoming).not_to include past_activity }
  end

  describe '.current' do
    let(:past_activity) do
      FactoryBot.create(:activity, start_time: 2.days.ago, end_time: 1.day.ago)
    end

    subject(:current_activity) do
      FactoryBot.create(:activity, start_time: 1.hour.ago, end_time: 2.hours.from_now)
    end

    it { expect(Activity.current).to include current_activity }
    it { expect(Activity.current).not_to include past_activity }
  end

  describe '#credit_mutations_total' do
    context 'when without credit mutations' do
      subject(:activity) { FactoryBot.build(:activity) }

      it { expect(activity.credit_mutations_total).to eq 0 }
    end

    context 'when with credit mutations' do
      subject(:activity) { FactoryBot.create(:activity) }

      before do
        FactoryBot.create(:credit_mutation, activity: activity, amount: 10)
        FactoryBot.create(:credit_mutation, activity: activity, amount: 50)
      end

      it { expect(activity.credit_mutations_total).to eq 60 }
    end
  end

  describe '#sold_products' do
    subject(:activity) { FactoryBot.create(:activity) }

    let(:product) { activity.price_list.products.sample }
    let(:order) { FactoryBot.create(:order, activity: activity) }

    before do
      FactoryBot.create(:order_row, product: product, order: order)
    end

    it { expect(activity.sold_products).to match_array [product] }
  end

  describe '#revenue' do
    subject(:activity) { FactoryBot.create(:activity) }

    let(:product) { activity.price_list.products.sample }
    let(:product_price) { activity.price_list.product_price_for(product).price }
    let(:order) { FactoryBot.create(:order, activity: activity) }

    before do
      FactoryBot.create(:order_row, product: product, order: order, product_count: 2)
    end

    it { expect(activity.revenue).to eq product_price * 2 }
  end

  describe '#revenue_by_category' do
    subject(:activity) { FactoryBot.create(:activity) }

    let(:product) { FactoryBot.create(:product, category: :beer) }
    let(:other_product) { FactoryBot.create(:product, category: :wine) }
    let(:order) { FactoryBot.create(:order, activity: activity) }

    before do
      FactoryBot.create(:product_price, price_list: activity.price_list, product: product, price: 2)
      FactoryBot.create(:product_price, price_list: activity.price_list, product: other_product, price: 3)

      FactoryBot.create(:order_row, order: order, product: product, product_count: 1)
      FactoryBot.create(:order_row, order: order, product: other_product, product_count: 1)
    end

    it { expect(activity.revenue_by_category(:beer)).to eq 2 }
  end

  describe '#bartenders' do
    subject(:activity) { FactoryBot.create(:activity) }

    let(:bartender) { FactoryBot.create(:user) }

    before do
      FactoryBot.create(:order, created_by: bartender, activity: activity)
    end

    it { expect(activity.bartenders).to match_array [bartender] }
  end
end
