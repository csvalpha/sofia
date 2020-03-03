require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:order) { FactoryBot.build_stubbed(:order) }

  describe '#valid' do
    it { expect(order).to be_valid }

    context 'when without user and without paid_with_cash' do
      subject(:order) { FactoryBot.build_stubbed(:order, user: nil) }

      it { expect(order).not_to be_valid }
    end

    context 'when without user with paid_with_cash' do
      subject(:order) { FactoryBot.build_stubbed(:order, user: nil, paid_with_cash: true) }

      it { expect(order).to be_valid }
    end

    context 'when without activity' do
      subject(:order) { FactoryBot.build_stubbed(:order, activity: nil) }

      it { expect(order).not_to be_valid }
    end

    context 'when without created by' do
      subject(:order) { FactoryBot.build_stubbed(:order, created_by: nil) }

      it { expect(order).not_to be_valid }
    end

    context 'when with locked activity' do
      let(:activity) { FactoryBot.build_stubbed(:activity, :locked) }
      let(:order) { FactoryBot.build(:order, activity: activity) }

      it { expect(order).not_to be_valid }
    end
  end

  describe '#order_total' do
    context 'when without rows' do
      subject(:order) { FactoryBot.create(:order) }

      it { expect(order.order_total).to eq 0 }
    end

    context 'when with one row' do
      let(:product) { FactoryBot.create(:product) }
      let(:price_list) { FactoryBot.create(:price_list, :with_products, products: [product]) }

      let(:activity) { FactoryBot.create(:activity, price_list: price_list) }

      subject(:order) { FactoryBot.create(:order, activity: activity) }

      before do
        FactoryBot.create(:order_row, order: order, product: product, product_count: 2)
        order.reload
      end

      it { expect(order.order_total).to eq(2 * price_list.product_price_for(product).price) }
    end
  end

  describe '#destroy' do
    let(:order) { FactoryBot.create(:order) }

    it { expect(order.destroy).to eq false }
  end

  describe '.by_manually_added_user' do
    let(:manually_added_user) { FactoryBot.create(:user) }
    let(:manually_added_user_order) { FactoryBot.create(:order, user: manually_added_user) }

    let(:provider_added_user) { FactoryBot.create(:user, provider: 'some_provider') }
    let(:provider_added_user_order) { FactoryBot.create(:order, user: provider_added_user) }

    before do
      manually_added_user_order
      provider_added_user_order
    end

    it { expect(described_class.by_manually_added_user).to include manually_added_user_order }
    it { expect(described_class.by_manually_added_user).not_to include provider_added_user_order }
  end
end
