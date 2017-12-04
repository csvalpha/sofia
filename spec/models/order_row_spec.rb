require 'rails_helper'

RSpec.describe OrderRow, type: :model do
  subject(:order_row) { FactoryBot.build(:order_row) }

  describe '#valid' do
    it { expect(order_row).to be_valid }

    context 'when without order' do
      subject(:order_row) { FactoryBot.build(:order_row, order: nil) }

      it { expect(order_row).not_to be_valid }
    end

    context 'when with a product not in this price list' do
      let(:other_product) { FactoryBot.build(:product) }

      subject(:order_row) { FactoryBot.build(:order_row, product: other_product) }

      it { expect(order_row).not_to be_valid }
    end
  end

  describe '#copy_product_price' do
    context 'when with a product' do
      let(:product) { FactoryBot.create(:product) }
      let(:price_list) { FactoryBot.create(:price_list) }
      let(:activity) { FactoryBot.create(:activity, price_list: price_list) }
      let(:order) { FactoryBot.create(:order, activity: activity) }

      subject(:order_row) { FactoryBot.create(:order_row, order: order, product: product) }

      before do
        FactoryBot.create(:product_price, price_list: price_list, product: product, price: 2.00)
      end

      it { expect(order_row.price_per_product).to eq(2.00) }
    end
  end

  describe '#available_products' do
    context 'when with an order' do
      let(:available_products) { FactoryBot.create_list(:product, 5) }
      let(:not_available_product) { FactoryBot.create(:product) }

      let(:price_list) { FactoryBot.create(:price_list, :with_specific_products, products: available_products) }
      let(:activity) { FactoryBot.create(:activity, price_list: price_list) }
      let(:order) { FactoryBot.create(:order, activity: activity) }

      subject(:order_row) { FactoryBot.create(:order_row, order: order) }

      it { expect(order_row.available_products).to match_array(available_products) }
    end
  end
end
