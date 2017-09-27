require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryGirl.build_stubbed(:user) }

  describe '#valid' do
    it { expect(user).to be_valid }

    context 'when without a username' do
      subject(:user) { FactoryGirl.build_stubbed(:user, username: nil) }

      it { expect(user).not_to be_valid }
    end
  end

  describe  '#credit' do
    subject(:user) { FactoryGirl.create(:user) }
    before do
      FactoryGirl.create(:transaction, user: user, amount: 20)
    end

    it { expect(user.credit).to eq -20 }
  end
end
