require 'rails_helper'

RSpec.describe Order, type: :model do
  subject(:order) { FactoryGirl.build_stubbed(:order) }

  describe '#valid' do
    it { expect(order).to be_valid }

    context 'when without user' do
      subject(:order) { FactoryGirl.build_stubbed(:order, user: nil) }

      it { expect(order).not_to be_valid }
    end

    context 'when without activity' do
      subject(:order) { FactoryGirl.build_stubbed(:order, activity: nil) }

      it { expect(order).not_to be_valid }
    end
  end

  describe '#calculate_product_price_total' do
    context 'when without rows' do
      subject(:order) { FactoryGirl.create(:order) }

      it { expect(order.order_total).to eq 0 }
    end

    context 'when with one row' do
      let(:price_list) { FactoryGirl.create(:price_list) }
      let(:product) { FactoryGirl.create(:product) }

      let(:activity) { FactoryGirl.create(:activity, price_list: price_list) }

      subject(:order) { FactoryGirl.create(:order, activity: activity) }

      before do
        FactoryGirl.create(:product_price, price_list: price_list, product: product, amount: 2.30)
        FactoryGirl.create(:order_row, order: order, product: product, product_count: 2)
        order.reload
      end

      it { expect(order.order_total).to eq(2 * 2.30) }
    end
  end
end
