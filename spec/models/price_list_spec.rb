require 'rails_helper'

RSpec.describe PriceList, type: :model do
  subject(:price_list) { FactoryGirl.build_stubbed(:price_list) }

  describe '#valid' do
    it { expect(price_list).to be_valid }

    context 'when without a name' do
      subject(:price_list) { FactoryGirl.build_stubbed(:price_list, name: nil) }

      it { expect(price_list).not_to be_valid }
    end
  end
end
