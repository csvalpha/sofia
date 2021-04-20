require 'rails_helper'

RSpec.describe Product, type: :model do
  subject(:product) { FactoryBot.build(:product) }

  describe '#valid' do
    it { expect(product).to be_valid }

    context 'when without a name' do
      subject(:product) { FactoryBot.build_stubbed(:product, name: nil) }

      it { expect(product).not_to be_valid }
    end

    context 'when without category' do
      subject(:product) { FactoryBot.build_stubbed(:product, category: nil) }

      it { expect(product).not_to be_valid }
    end

    context 'when updating the name' do
      subject(:product) { FactoryBot.create(:product) }

      it { expect(product.update(name: 'new_name')).to eq false }
    end
  end

  describe '#requires_age' do
    context 'when with requires age category' do
      subject(:product) { FactoryBot.create(:product, category: %w[beer distilled wine tobacco].sample) }

      it { expect(product.requires_age).to eq true }
    end

    context 'when with non requires age category' do
      subject(:product) { FactoryBot.create(:product, category: %w[food non_alcoholic].sample) }

      it { expect(product.requires_age).to eq false }
    end
  end

  describe 't_category' do
    subject(:product) { FactoryBot.build(:product, category: :beer) }

    it { expect(product.t_category).to eq 'bier' }
  end
end
