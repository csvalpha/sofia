require 'rails_helper'

RSpec.describe Transaction, type: :model do
  subject(:transaction) { FactoryGirl.build_stubbed(:transaction) }

  describe '#valid' do
    it { expect(transaction).to be_valid }

    context 'when without timestamp' do
      subject(:transaction) { FactoryGirl.build_stubbed(:transaction, timestamp: nil) }

      it { expect(transaction).not_to be_valid }
      end

    context 'when without amount' do
      subject(:transaction) { FactoryGirl.build_stubbed(:transaction, amount: nil) }

      it { expect(transaction).not_to be_valid }
    end

    context 'when amount is changed' do
      subject(:transaction) { FactoryGirl.create(:transaction) }
      before do
        transaction.amount = 280
      end

      it { expect(transaction.save).to be false }
    end
  end
end
