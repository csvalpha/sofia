require 'rails_helper'

RSpec.describe ProductPrice do
  subject(:product_price) { build_stubbed(:product_price) }

  describe '#valid' do
    it { expect(product_price).to be_valid }

    context 'when without a price' do
      subject(:product_price) { build_stubbed(:product_price, price: nil) }

      it { expect(product_price).not_to be_valid }
    end

    context 'when with too high price' do
      subject(:product_price) { build_stubbed(:product_price, price: 101) }

      it { expect(product_price).not_to be_valid }
    end

    context 'when without a list' do
      subject(:product_price) { build_stubbed(:product_price, price_list: nil) }

      it { expect(product_price).not_to be_valid }
    end

    context 'when without a product' do
      subject(:product_price) { build_stubbed(:product_price, product: nil) }

      it { expect(product_price).not_to be_valid }
    end

    context 'when with a negative position' do
      subject(:product_price) { build_stubbed(:product_price, position: -1) }

      it { expect(product_price).not_to be_valid }
    end

    context 'when with a duplicate product for the same price_list' do
      subject(:product_price) { build(:product_price, product: existing.product, price_list: existing.price_list) }

      let(:existing) { create(:product_price) }

      it { expect(product_price).not_to be_valid }
    end
  end

  describe '#set_default_position' do
    subject(:price_list) { create(:price_list, :with_products, products: []) }

    it 'assigns position 0 to the first product_price without a folder' do
      product_price = create(:product_price, price_list:, position: nil)
      expect(product_price.position).to eq 0
    end

    it 'assigns the next position after existing product_prices without a folder' do
      create(:product_price, price_list:, position: 0)
      product_price = create(:product_price, price_list:, position: nil)
      expect(product_price.position).to eq 1
    end

    it 'tracks positions per folder separately' do
      folder = create(:product_price_folder, price_list:)
      create(:product_price, price_list:, position: 0)
      product_price = create(:product_price, price_list:, product_price_folder: folder, position: nil)
      expect(product_price.position).to eq 0
    end
  end

  describe '.without_folder' do
    it 'only returns product_prices without a folder' do
      folder = create(:product_price_folder)
      in_folder = create(:product_price, price_list: folder.price_list, product_price_folder: folder)
      without_folder = create(:product_price, price_list: folder.price_list)

      expect(described_class.without_folder).to include(without_folder)
      expect(described_class.without_folder).not_to include(in_folder)
    end
  end

  describe '.in_folder' do
    it 'only returns product_prices in the given folder' do
      folder = create(:product_price_folder)
      in_folder = create(:product_price, price_list: folder.price_list, product_price_folder: folder)
      without_folder = create(:product_price, price_list: folder.price_list)

      expect(described_class.in_folder(folder)).to include(in_folder)
      expect(described_class.in_folder(folder)).not_to include(without_folder)
    end
  end
end
