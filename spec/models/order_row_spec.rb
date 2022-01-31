require 'rails_helper'

RSpec.describe OrderRow, type: :model do
  subject(:order_row) { create(:order_row) }

  describe '#valid' do
    it { expect(order_row).to be_valid }

    context 'when without order' do
      subject(:order_row) { build(:order_row, order: nil) }

      it { expect(order_row).not_to be_valid }
    end

    context 'when with a product not in this price list' do
      let(:other_product) { build(:product) }

      subject(:order_row) { build(:order_row, product: other_product) }

      it { expect(order_row).not_to be_valid }
    end

    context 'when changing price_per_product' do
      let(:new_price) { order_row.price_per_product + 1.00 }

      before { order_row.assign_attributes(price_per_product: new_price) }

      it { expect(order_row).not_to be_valid }
    end
  end

  describe '#copy_product_price' do
    let(:product) { create(:product) }
    let(:price_list) { create(:price_list) }
    let(:activity) { create(:activity, price_list: price_list) }
    let(:order) { create(:order, activity: activity) }
    let!(:product_price) do
      create(:product_price, price_list: price_list, product: product, price: 2.00)
    end

    subject!(:order_row) { create(:order_row, order: order, product: product) }

    context 'when with a product' do
      it { expect(order_row.price_per_product).to eq(2.00) }
    end

    context 'when product_price changes after creation' do
      before do
        product_price.update(price: 44.00)
      end

      it { expect(order_row.price_per_product).to eq(2.00) }
    end

    context 'when product_price is deleted after creation' do
      before do
        product_price.delete
      end

      it { expect(order_row.price_per_product).to eq(2.00) }
    end
  end

  describe '#available_products' do
    context 'when with an order' do
      let(:all_products) { create_list(:product, 5) }
      let(:price_list) { create(:price_list, :with_products, products: all_products) }
      let(:activity) { create(:activity, price_list: price_list) }
      let(:order) { create(:order, activity: activity) }

      subject(:order_row) { create(:order_row, order: order) }

      before { create(:product) }

      it { expect(order_row.available_products).to match_array(all_products) }
    end
  end

  describe '#destroy' do
    let(:order) { create(:order) }

    it { expect(order.destroy).to eq false }
  end
end
