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

  describe '#after_save' do
    subject(:payment) { FactoryBot.create(:payment, status: 'open') }

    context 'when updating payment to paid' do
      before do
        allow(payment).to receive(:process_complete_payment!)

        payment.update(status: 'paid')
      end

      it { expect(payment).to have_received(:process_complete_payment!) }
    end

    context 'when not updating payment to paid' do
      before do
        allow(payment).to receive(:process_complete_payment!)

        Payment.statuses.each do |status, *|
          next if status == 'paid'

          payment.update(status: status)
        end
      end

      it { expect(payment).to_not have_received(:process_complete_payment!) }
    end
  end

  describe '#process_complete_payment!' do
    context 'with user' do
      subject(:payment) { FactoryBot.create(:payment, status: 'paid') }

      before do
        allow(payment).to receive(:process_user!)
        allow(payment).to receive(:process_invoice!)

        payment.process_complete_payment!
      end

      it { expect(payment).to have_received(:process_user!) }
      it { expect(payment).to_not have_received(:process_invoice!) }
    end

    context 'with invoice' do
      subject(:payment) { FactoryBot.create(:payment, :invoice, status: 'paid') }

      before do
        allow(payment).to receive(:process_user!)
        allow(payment).to receive(:process_invoice!)

        payment.process_complete_payment!
      end

      it { expect(payment).to have_received(:process_invoice!) }
      it { expect(payment).to_not have_received(:process_user!) }
    end
  end

  describe '#process_user!' do
    let(:user) { FactoryBot.create(:user) }

    subject(:payment) { FactoryBot.create(:payment, user: user, amount: 22.00, status: 'paid') }

    before do
      payment.process_user!
    end

    it { expect(user.credit_mutations.last.description).to eq 'iDEAL inleg' }
    it { expect(user.credit_mutations.last.amount).to eq 22.00 }
  end

  describe '#process_invoice!' do
    let(:user) { FactoryBot.create(:user) }
    let(:invoice_row) { FactoryBot.create(:invoice_row, amount: 1, price: 22.00) }
    let(:invoice) { FactoryBot.create(:invoice, rows: [invoice_row], user: user) }

    subject(:payment) { FactoryBot.create(:payment, user: nil, invoice: invoice, amount: invoice.amount, status: 'paid') }

    before do
      payment.process_invoice!
    end

    it { expect(invoice.status).to eq 'paid' }
    it { expect(user.credit_mutations.last.description).to eq "Betaling factuur #{invoice.human_id}" }
  end
end
