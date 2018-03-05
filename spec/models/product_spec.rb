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

    context 'when without requires_age' do
      subject(:product) { FactoryBot.build_stubbed(:product, requires_age: nil) }

      it { expect(product).not_to be_valid }
    end
  end

  describe 't_category' do
    subject(:product) { FactoryBot.build(:product, category: :beer) }

    it { expect(product.t_category).to eq 'bier' }
  end
end
