require 'rails_helper'

RSpec.describe OrderRow, type: :model do
  subject(:order_row) { FactoryGirl.build(:order_row) }

  describe '#valid' do
    it { expect(order_row).to be_valid }

    context 'when without product' do
      subject(:order_row) { FactoryGirl.build(:order_row, product: nil) }

      it { expect(order_row).not_to be_valid }
    end

    context 'when without order' do
      subject(:order_row) { FactoryGirl.build(:order_row, order: nil) }

      it { expect(order_row).not_to be_valid }
    end

    context 'when with a product not in this price list' do
      let(:product) { FactoryGirl.create(:product) }
      let(:other_product) { FactoryGirl.create(:product) }

      subject(:order_row) { FactoryGirl.create(:order_row, product: product) }

      before do
        FactoryGirl.create(:product_price, price_list: order_row.order.activity.price_list, product: other_product)
      end

      it { expect(order_row).not_to be_valid }
    end
  end

  describe '#calculate_product_price_total' do
    context 'when with one product' do
      let(:price_list) { FactoryGirl.create(:price_list) }
      let(:product) { FactoryGirl.create(:product) }

      let(:activity) { FactoryGirl.create(:activity, price_list: price_list) }
      let(:order) { FactoryGirl.create(:order, activity: activity) }

      subject(:order_row) { FactoryGirl.create(:order_row, order: order, product: product, product_count: 2) }

      before do
        FactoryGirl.create(:product_price, price_list: price_list, product: product, amount: 2.30)
      end

      it { expect(order_row.product_price_total).to eq(2 * 2.30) }
    end
  end
end
