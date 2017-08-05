require 'rails_helper'

RSpec.describe Activity, type: :model do
  subject(:activity) { FactoryGirl.build_stubbed(:activity) }

  describe '#valid' do
    it { expect(activity).to be_valid }

    context 'when without a title' do
      subject(:activity) { FactoryGirl.build_stubbed(:activity, title: nil) }

      it { expect(activity).not_to be_valid }
    end

    context 'when without a price list' do
      subject(:activity) { FactoryGirl.build_stubbed(:activity, price_list: nil)}

      it { expect(activity).not_to be_valid }
    end
  end
end
