require 'rails_helper'

RSpec.describe Product, type: :model do
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

      it { expect(product.update(name: 'new_name')).to be false }
    end
  end

  describe '#requires_age' do
    context 'when with requires age category' do
      subject(:product) { create(:product, category: %w[beer craft_beer distilled wine tobacco].sample) }

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
