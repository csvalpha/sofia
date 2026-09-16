require 'rails_helper'

RSpec.describe PriceList do
  subject(:price_list) { build_stubbed(:price_list) }

  describe '#valid' do
    it { expect(price_list).to be_valid }

    context 'when without a name' do
      subject(:price_list) { build_stubbed(:price_list, name: nil) }

      it { expect(price_list).not_to be_valid }
    end

    context 'when with a grid_size below the minimum' do
      subject(:price_list) { build_stubbed(:price_list, grid_size: 1) }

      it { expect(price_list).not_to be_valid }
    end

    context 'when with a grid_size above the maximum' do
      subject(:price_list) { build_stubbed(:price_list, grid_size: 10) }

      it { expect(price_list).not_to be_valid }
    end

    context 'when without a grid_size' do
      subject(:price_list) { build_stubbed(:price_list, grid_size: nil) }

      it { expect(price_list).to be_valid }
    end
  end

  describe '#set_defaults' do
    it 'defaults grid_size to 4 when not given' do
      expect(described_class.new.grid_size).to eq 4
    end

    it 'does not override an explicitly given grid_size' do
      expect(described_class.new(grid_size: 6).grid_size).to eq 6
    end
  end

  describe '#product_price_for' do
    subject(:price_list) { create(:price_list) }

    let(:product) { create(:product) }

    before do
      create(:product_price, product:, price_list:, price: 8)
    end

    it { expect(price_list.product_price_for(product).price).to eq 8 }
  end

  describe '#to_s' do
    subject(:price_list) { create(:price_list) }

    it { expect(price_list.to_s).to eq price_list.name }
  end
end
