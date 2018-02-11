require 'rails_helper'

RSpec.describe CreditMutation, type: :model do
  subject(:mutation) { FactoryBot.build_stubbed(:credit_mutation) }

  describe '#valid' do
    it { expect(mutation).to be_valid }

    context 'when without a description' do
      subject(:mutation) { FactoryBot.build_stubbed(:credit_mutation, description: nil) }

      it { expect(mutation).not_to be_valid }
    end

    context 'when without an user' do
      subject(:mutation) { FactoryBot.build_stubbed(:credit_mutation, user: nil) }

      it { expect(mutation).not_to be_valid }
    end

    context 'when without a created by' do
      subject(:mutation) { FactoryBot.build_stubbed(:credit_mutation, created_by: nil) }

      it { expect(mutation).not_to be_valid }
    end

    context 'when without an amount' do
      subject(:mutation) { FactoryBot.build_stubbed(:credit_mutation, amount: nil) }

      it { expect(mutation).not_to be_valid }
    end

    context 'when with a locked activity' do
      let(:activity) { FactoryBot.build(:activity, :locked) }
      let(:mutation) { FactoryBot.build(:credit_mutation, activity: activity) }

      it { expect(mutation).not_to be_valid }
    end
  end
end
