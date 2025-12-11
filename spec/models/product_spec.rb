require 'rails_helper'

RSpec.describe Product do
  subject(:product) { build(:product) }

  describe '#valid' do
    it { expect(product).to be_valid }

    context 'when without a name' do
      subject(:product) { build_stubbed(:product, name: nil) }

      it { expect(product).not_to be_valid }
    end

    context 'when without category' do
      subject(:product) { build_stubbed(:product, category: nil) }

      it { expect(product).not_to be_valid }
    end

    context 'when updating the name' do
      subject(:product) { create(:product) }

      it { expect(product.update(name: 'new_name')).to be true }
    end
  end

  describe 'color validation' do
    context 'with valid 6-digit hex color' do
      subject(:product) { build(:product, color: '#FF5733') }

      it { expect(product).to be_valid }
    end

    context 'with valid 3-digit hex color' do
      subject(:product) { build(:product, color: '#F57') }

      it { expect(product).to be_valid }
    end

    context 'with lowercase hex color' do
      subject(:product) { build(:product, color: '#ff5733') }

      it { expect(product).to be_valid }
    end

    context 'with mixed case hex color' do
      subject(:product) { build(:product, color: '#Ff5733') }

      it { expect(product).to be_valid }
    end

    context 'with blank color' do
      subject(:product) { build(:product, color: '') }

      it { expect(product).not_to be_valid }
    end

    context 'with nil color' do
      subject(:product) { build(:product, color: nil) }

      it { expect(product).not_to be_valid }
    end

    context 'with invalid color string' do
      subject(:product) { build(:product, color: 'red') }

      it { expect(product).not_to be_valid }
    end

    context 'with invalid hex format missing hash' do
      subject(:product) { build(:product, color: 'FF5733') }

      it { expect(product).not_to be_valid }
    end

    context 'with invalid hex with too many digits' do
      subject(:product) { build(:product, color: '#FF57330') }

      it { expect(product).not_to be_valid }
    end

    context 'with invalid hex with too few digits' do
      subject(:product) { build(:product, color: '#F5') }

      it { expect(product).not_to be_valid }
    end

    context 'with non-hex characters' do
      subject(:product) { build(:product, color: '#GG5733') }

      it { expect(product).not_to be_valid }
    end
  end

  describe '#requires_age' do
    context 'when with requires age category' do
      subject(:product) { create(:product, category: %w[beer craft_beer distilled whiskey wine tobacco].sample) }

      it { expect(product.requires_age).to be true }
    end

    context 'when with non requires age category' do
      subject(:product) { create(:product, category: %w[food non_alcoholic donation].sample) }

      it { expect(product.requires_age).to be false }
    end
  end

  describe 't_category' do
    subject(:product) { build(:product, category: :beer) }

    it { expect(product.t_category).to eq 'bier' }
  end
end
