require 'rails_helper'

RSpec.describe ProductPriceFolder do
  subject(:product_price_folder) { build_stubbed(:product_price_folder) }

  describe '#valid' do
    it { expect(product_price_folder).to be_valid }

    context 'when without a name' do
      subject(:product_price_folder) { build_stubbed(:product_price_folder, name: nil) }

      it { expect(product_price_folder).not_to be_valid }
    end

    context 'when without a color' do
      subject(:product_price_folder) { build_stubbed(:product_price_folder, color: nil) }

      it { expect(product_price_folder).not_to be_valid }
    end

    context 'when with an invalid color' do
      subject(:product_price_folder) { build_stubbed(:product_price_folder, color: 'not-a-hexcode') }

      it { expect(product_price_folder).not_to be_valid }
    end

    context 'when with a short hexcode color' do
      subject(:product_price_folder) { build_stubbed(:product_price_folder, color: '#F57') }

      it { expect(product_price_folder).to be_valid }
    end

    context 'when without a price_list' do
      subject(:product_price_folder) { build_stubbed(:product_price_folder, price_list: nil) }

      it { expect(product_price_folder).not_to be_valid }
    end

    context 'when with a negative position' do
      subject(:product_price_folder) { build_stubbed(:product_price_folder, position: -1) }

      it { expect(product_price_folder).not_to be_valid }
    end
  end

  describe '#set_default_position' do
    subject(:price_list) { create(:price_list) }

    it 'assigns position 0 to the first folder' do
      folder = create(:product_price_folder, price_list:, position: nil)
      expect(folder.position).to eq 0
    end

    it 'assigns the next position after existing folders' do
      create(:product_price_folder, price_list:, position: 0)
      folder = create(:product_price_folder, price_list:, position: nil)
      expect(folder.position).to eq 1
    end
  end

  describe 'default scope' do
    subject(:price_list) { create(:price_list) }

    it 'orders folders by position' do
      second = create(:product_price_folder, price_list:, position: 1)
      first = create(:product_price_folder, price_list:, position: 0)
      expect(price_list.product_price_folders).to eq [first, second]
    end
  end

  describe '#destroy' do
    it 'nullifies the folder on associated product_prices' do
      folder = create(:product_price_folder)
      product_price = create(:product_price, price_list: folder.price_list, product_price_folder: folder)

      folder.destroy

      expect(product_price.reload.product_price_folder_id).to be_nil
    end
  end
end
