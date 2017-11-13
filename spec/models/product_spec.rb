require 'rails_helper'

RSpec.describe Product, type: :model do
  subject(:product) { FactoryGirl.build_stubbed(:product) }

  describe '#valid' do
    it { expect(product).to be_valid }

    context 'when without a name' do
      subject(:product) { FactoryGirl.build_stubbed(:product, name: nil) }

      it { expect(product).not_to be_valid }
    end

    context 'when without requires_age' do
      subject(:product) { FactoryGirl.build_stubbed(:product, requires_age: nil) }

      it { expect(product).not_to be_valid }
    end
  end
end
