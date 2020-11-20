require 'rails_helper'

RSpec.describe Payment, type: :model do
  subject(:payment) { FactoryBot.build_stubbed(:payment) }

  describe '#valid' do
    it { expect(payment).to be_valid }

    context 'when without user and invoice' do
      subject(:payment) { FactoryBot.build_stubbed(:payment, user: nil, invoice: nil) }

      it { expect(payment).not_to be_valid }
    end

    context 'when with user and invoice' do
      subject(:payment) { FactoryBot.build_stubbed(:payment, invoice: FactoryBot.create(:invoice)) }

      it { expect(payment).not_to be_valid }
    end

    context 'when without an amount' do
      subject(:payment) { FactoryBot.build_stubbed(:payment, amount: nil) }

      it { expect(payment).not_to be_valid }
    end

    context 'when with too few amount' do
      context 'when with user' do
        subject(:payment) { FactoryBot.build_stubbed(:payment, amount: 19) }

        it { expect(payment).not_to be_valid }
      end

      context 'when with invoice' do
        subject(:payment) { FactoryBot.build_stubbed(:payment, :invoice, amount: 19) }

        it { expect(payment).to be_valid }
      end

    end

    context 'when without a status' do
      subject(:payment) { FactoryBot.build_stubbed(:payment, status: nil) }

      it { expect(payment).not_to be_valid }
    end
  end

  describe '.not_completed' do
    context 'when with not_completed status' do
      %w[open pending].each do |status|
        subject(:payment) { FactoryBot.create(:payment, status: status) }

        before { payment }

        it { expect(described_class.not_completed).to include payment }
      end
    end

    context 'when with complete status' do
      %w[paid failed canceled expired].each do |status|
        subject(:payment) { FactoryBot.create(:payment, status: status) }

        before { payment }

        it { expect(described_class.not_completed).not_to include payment }
      end
    end
  end
end
