require 'rails_helper'

RSpec.describe Invoice, type: :model do
  subject(:invoice) { FactoryBot.build_stubbed(:invoice) }

  describe '#valid' do
    it { expect(invoice).to be_valid }

    context 'when without user' do
      subject(:invoice) { FactoryBot.build_stubbed(:invoice, user: nil) }

      it { expect(invoice).not_to be_valid }
    end

    context 'when without activity' do
      subject(:invoice) { FactoryBot.build_stubbed(:invoice, activity: nil) }

      it { expect(invoice).not_to be_valid }
    end

    context 'when without amount' do
      subject(:invoice) { FactoryBot.build_stubbed(:invoice, amount: nil) }

      it { expect(invoice).not_to be_valid }
    end
  end
end
