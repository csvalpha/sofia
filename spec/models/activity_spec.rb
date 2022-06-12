require 'rails_helper'

RSpec.describe Activity, type: :model do
  subject(:activity) { build_stubbed(:activity) }

  describe '#valid' do
    it { expect(activity).to be_valid }

    context 'when without a title' do
      subject(:activity) { build_stubbed(:activity, title: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without a price list' do
      subject(:activity) { build_stubbed(:activity, price_list: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without a start time' do
      subject(:activity) { build_stubbed(:activity, start_time: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without an end time' do
      subject(:activity) { build_stubbed(:activity, end_time: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without a created by' do
      subject(:activity) { build_stubbed(:activity, created_by: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when start time is after end time' do
      subject(:activity) do
        build_stubbed(:activity,
                      start_time: 1.second.from_now,
                      end_time: Time.zone.now)
      end

      it { expect(activity).not_to be_valid }
    end
  end

  describe 'cannot alter an activity when locked' do
    before { activity.title = "#{activity.title}_new" }

    context 'when within two months' do
      subject(:activity) { build(:activity) }

      it { expect(activity).to be_valid }
    end

    context 'when after two months' do
      subject(:activity) { build(:activity, :locked) }

      it { expect(activity).not_to be_valid }
    end

    context 'when locked manually' do
      subject(:activity) { build(:activity, :manually_locked) }

      it { expect(activity).not_to be_valid }
    end
  end

  describe 'cannot destroy an activity when locked' do
    context 'when within two months' do
      subject(:activity) { build(:activity) }

      it { expect(activity.destroy).to eq activity }
    end

    context 'when after two months' do
      subject(:activity) { build(:activity, :locked) }

      it { expect(activity.destroy).to be false }
    end

    context 'when manually locked' do
      subject(:activity) { build(:activity, :manually_locked) }

      it { expect(activity.destroy).to be false }
    end
  end

  describe '#lock_date' do
    let(:start_time) { (2.months + 3.days).ago }

    subject(:activity) { build(:activity, start_time: start_time, end_time: start_time + 4.hours) }

    it { expect(activity.lock_date).to eq activity.end_time + 2.months }
    it { expect(activity.locked?).to be true }

    context 'when with recent activity' do
      subject(:activity) { build(:activity) }

      it { expect(activity.locked?).to be false }
    end
  end

  describe '#destroyable' do
    context 'when locked' do
      let(:activity) { create(:activity, :locked) }

      it { expect(activity.destroyable?).to be false }
    end

    context 'when with orders' do
      let(:activity) { create(:activity) }

      before do
        create(:order, activity: activity)
      end

      it { expect(activity.destroyable?).to be false }
    end

    context 'when with credit mutations' do
      let(:activity) { create(:activity) }

      before do
        create(:credit_mutation, activity: activity)
      end

      it { expect(activity.destroyable?).to be false }
    end

    context 'when empty' do
      let(:activity) { create(:activity) }

      it { expect(activity.destroyable?).to be true }
    end
  end

  describe '.upcoming' do
    let(:past_activity) do
      create(:activity, start_time: 2.days.ago, end_time: 1.day.ago)
    end

    subject(:future_activity) do
      create(:activity, start_time: 1.day.from_now, end_time: 2.days.from_now)
    end

    it { expect(described_class.upcoming).to include future_activity }
    it { expect(described_class.upcoming).not_to include past_activity }
  end

  describe '.current' do
    let(:past_activity) do
      create(:activity, start_time: 2.days.ago, end_time: 1.day.ago)
    end

    subject(:current_activity) do
      create(:activity, start_time: 1.hour.ago, end_time: 2.hours.from_now)
    end

    it { expect(described_class.current).to include current_activity }
    it { expect(described_class.current).not_to include past_activity }
  end

  describe '.not_locked' do
    let(:not_locked_activity) { create(:activity) }
    let(:time_locked_activity) { create(:activity, :locked) }
    let(:manually_locked_activity) { create(:activity, :manually_locked) }

    before do
      not_locked_activity
      time_locked_activity
      manually_locked_activity
    end

    it { expect(described_class.not_locked.size).to eq 1 }
    it { expect(described_class.not_locked).to include not_locked_activity }
  end

  describe 'reporting' do
    subject(:activity) { create(:activity) }

    describe '#credit_mutations_total' do
      context 'when without credit mutations' do
        it { expect(activity.credit_mutations_total).to eq 0 }
      end

      context 'when with credit mutations' do
        before do
          create(:credit_mutation, activity: activity, amount: 10)
          create(:credit_mutation, activity: activity, amount: 50)
        end

        it { expect(activity.credit_mutations_total).to eq 60 }
      end
    end

    describe '#revenue_with(out)_cash' do
      let(:product) { activity.price_list.products.sample }
      let(:product_price) { activity.price_list.product_price_for(product).price }
      let(:cash_order) { create(:order, :cash, activity: activity) }
      let(:pin_order) { create(:order, :pin, activity: activity) }
      let(:order) { create(:order, activity: activity) }

      before do
        create(:order_row, product: product, order: cash_order, product_count: 2)
        create(:order_row, product: product, order: order, product_count: 3)
        create(:order_row, product: product, order: pin_order, product_count: 4)
      end

      it { expect(activity.revenue_with_cash).to eq product_price * 2 }
      it { expect(activity.revenue_with_credit).to eq product_price * 3 }
      it { expect(activity.revenue_with_pin).to eq product_price * 4 }
      it { expect(activity.revenue_with_cash).not_to eq activity.revenue_with_credit }
    end

    describe '#cash_total' do
      let(:product) { activity.price_list.products.sample }
      let(:product_price) { activity.price_list.product_price_for(product).price }
      let(:cash_order) { create(:order, :cash, activity: activity) }
      let(:pin_order) { create(:order, :pin, activity: activity) }
      let(:order) { create(:order, activity: activity) }

      before do
        create(:credit_mutation, activity: activity, amount: 50)
        create(:order_row, product: product, order: cash_order, product_count: 2)
        create(:order_row, product: product, order: order, product_count: 3)
        create(:order_row, product: product, order: pin_order, product_count: 4)
      end

      it { expect(activity.cash_total).to eq (2 * product_price) + 50 }
    end

    describe '#revenue_total' do
      let(:product) { activity.price_list.products.sample }
      let(:product_price) { activity.price_list.product_price_for(product).price }
      let(:cash_order) { create(:order, :cash, activity: activity) }
      let(:pin_order) { create(:order, :pin, activity: activity) }
      let(:order) { create(:order, activity: activity) }

      before do
        create(:credit_mutation, activity: activity, amount: 50)
        create(:order_row, product: product, order: cash_order, product_count: 2)
        create(:order_row, product: product, order: order, product_count: 3)
        create(:order_row, product: product, order: pin_order, product_count: 4)
      end

      it { expect(activity.revenue_total).to eq 9 * product_price }
    end

    describe '#count_per_product' do
      let(:products) { activity.price_list.products.sample(2) }
      let(:unbound_order) { create(:order, activity: activity) }

      before do
        create(:order_row, order: order, product_count: 2, product: products.first)
        create(:order_row, order: order, product_count: 3, product: products.last)
        create(:order_row, order: unbound_order, product_count: 4, product: products.first)
      end

      context 'without arguments' do
        let(:order) { create(:order, activity: activity) }

        it { expect(activity.count_per_product.find { |item| item[:name] == products.first[:name] }[:amount]).to eq 6 }
        it { expect(activity.count_per_product.find { |item| item[:name] == products.last[:name] }[:amount]).to eq 3 }
      end

      context 'when specific user' do
        let(:user) { create(:user) }
        let(:order) { create(:order, activity: activity, user: user) }

        it { expect(activity.count_per_product(user: user).find { |item| item[:name] == products.first[:name] }[:amount]).to eq 2 }
        it { expect(activity.count_per_product(user: user).find { |item| item[:name] == products.last[:name] }[:amount]).to eq 3 }
      end

      context 'when paid with pin' do
        let(:order) { create(:order, activity: activity, paid_with_pin: true) }

        it { expect(activity.count_per_product(paid_with_pin: true).find { |item| item[:name] == products.first[:name] }[:amount]).to eq 2 }
        it { expect(activity.count_per_product(paid_with_pin: true).find { |item| item[:name] == products.last[:name] }[:amount]).to eq 3 }
      end

      context 'when paid with cash' do
        let(:order) { create(:order, activity: activity, paid_with_cash: true) }
        let(:count_per_product) { activity.count_per_product(paid_with_cash: true) }

        it { expect(count_per_product.find { |item| item[:name] == products.first[:name] }[:amount]).to eq 2 }
        it { expect(count_per_product.find { |item| item[:name] == products.last[:name] }[:amount]).to eq 3 }
      end
    end

    describe '#revenue_by_category' do
      let(:product) { create(:product, category: :beer) }
      let(:other_product) { create(:product, category: :wine) }
      let(:order) { create(:order, activity: activity) }

      before do
        create(:product_price, price_list: activity.price_list, product: product, price: 2)
        create(:product_price, price_list: activity.price_list, product: other_product, price: 3)

        create(:order_row, order: order, product: product, product_count: 1)
        create(:order_row, order: order, product: other_product, product_count: 1)
      end

      it { expect(activity.revenue_by_category['beer']).to eq 2 }
    end

    describe '#revenue_per_product' do
      let(:product) { create(:product, category: :beer) }
      let(:other_product) { create(:product, category: :wine) }
      let(:order) { create(:order, activity: activity) }

      before do
        create(:product_price, price_list: activity.price_list, product: product, price: 2)
        create(:product_price, price_list: activity.price_list, product: other_product, price: 3)

        create(:order_row, order: order, product: product, product_count: 1)
        create(:order_row, order: order, product: other_product, product_count: 1)
      end

      it { expect(activity.revenue_per_product[product]).to eq 2 }
    end

    describe '#revenue_by_user' do
      let(:user) { create(:user) }
      let(:price) { create(:product_price, price: 2) }
      let(:activity) { create(:activity, price_list: price.price_list) }
      let(:order) { create(:order, activity: activity, user: user) }

      before do
        create(:order_row, order: order, product: price.product, product_count: 10)
        create(:order_row, order: order, product: price.product, product_count: 40)
      end

      it { expect(activity.revenue_by_user(user)).to eq 100 }
    end

    describe '#bartenders' do
      let(:bartender) { create(:user) }

      before do
        create(:order, created_by: bartender, activity: activity)
      end

      it { expect(activity.bartenders).to match_array [bartender] }
    end
  end

  describe '#locked?' do
    subject(:activity) { build_stubbed(:activity, :locked) }

    it { expect(activity.locked?).to be true }
  end

  describe '#manually_added_users_with_orders' do
    subject(:activity) { create(:activity) }

    let(:manually_added_user) { create(:user) }
    let(:manually_added_user_order) { create(:order, user: manually_added_user, activity: activity) }

    # Make sure that a user only shows up once in the list, even if he/she has placed multiple orders
    let(:second_manually_added_user_order) { create(:order, user: manually_added_user, activity: activity) }

    let(:provider_added_user) { create(:user, provider: 'some_provider') }
    let(:provider_added_user_order) { create(:order, user: provider_added_user, activity: activity) }

    before do
      manually_added_user_order
      second_manually_added_user_order
      provider_added_user_order
    end

    it { expect(activity.manually_added_users_with_orders).to eq [manually_added_user] }
  end
end
