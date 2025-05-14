require 'rails_helper'

RSpec.describe Payment do
  subject(:payment) { build_stubbed(:payment) }

  describe '#valid' do
    it { expect(payment).to be_valid }

    context 'when without user and invoice' do
      subject(:payment) { build_stubbed(:payment, user: nil, invoice: nil) }

      it { expect(payment).not_to be_valid }
    end

    context 'when with user and invoice' do
      subject(:payment) { build_stubbed(:payment, invoice: create(:invoice)) }

      it { expect(payment).not_to be_valid }
    end

    context 'when without an amount' do
      subject(:payment) { build_stubbed(:payment, amount: nil) }

      it { expect(payment).not_to be_valid }
    end

    context 'when with too few amount' do
      context 'when with user' do
        subject(:payment) { build_stubbed(:payment, amount: 19) }

        it { expect(payment).not_to be_valid }
      end

      context 'when with invoice' do
        subject(:payment) { build_stubbed(:payment, :invoice, amount: 19) }

        it { expect(payment).to be_valid }
      end
    end

    context 'when without a status' do
      subject(:payment) { build_stubbed(:payment, status: nil) }

      it { expect(payment).not_to be_valid }
    end
  end

  describe '.not_completed' do
    context 'when with not_completed status' do
      %w[open pending].each do |status|
        subject(:payment) { create(:payment, status:) }

        before { payment }

        it { expect(described_class.not_completed).to include payment }
      end
    end

    context 'when with complete status' do
      %w[paid failed canceled expired].each do |status|
        subject(:payment) { create(:payment, status:) }

        before { payment }

        it { expect(described_class.not_completed).not_to include payment }
      end
    end
  end

  describe '#after_save' do
    let(:user) { create(:user) }

    context 'when updating user payment to paid' do
      subject(:payment) { create(:payment, user:, amount: 22.00, status: 'open') }

      describe 'creates credit mutation' do
        before do
          payment.update(status: 'paid')
        end

        it { expect(user.credit_mutations.last.description).to eq 'iDEAL inleg' }
        it { expect(user.credit_mutations.last.amount).to eq 22.00 }
      end

      describe 'enqueues mail' do
        it { expect { payment.update(status: 'paid') }.to have_enqueued_mail(UserCreditMailer, :new_credit_mutation_mail) }
      end
    end

    context 'when updating invoice payment to paid' do
      let(:invoice_row) { create(:invoice_row, amount: 1, price: 22.00) }
      let(:invoice) { create(:invoice, rows: [invoice_row], user:) }

      subject(:payment) { create(:payment, user: nil, invoice:, amount: invoice.amount, status: 'open') }

      describe 'creates credit mutation' do
        before do
          payment.update(status: 'paid')
        end

        it { expect(invoice.status).to eq 'paid' }
        it { expect(user.credit_mutations.last.description).to eq "Betaling factuur #{invoice.human_id}" }
        it { expect(user.credit_mutations.last.amount).to eq 22.00 }
      end

      describe 'enqueues mail' do
        it { expect { payment.update(status: 'paid') }.to have_enqueued_mail(InvoiceMailer, :invoice_paid) }
      end
    end

    context 'when not updating payment to paid' do
      subject(:payment) { create(:payment, user:, amount: 22.00, status: 'open') }

      it { expect { payment.update(status: 'open') }.not_to change(CreditMutation, :count) }
      it { expect { payment.update(status: 'pending') }.not_to change(CreditMutation, :count) }
      it { expect { payment.update(status: 'failed') }.not_to change(CreditMutation, :count) }
      it { expect { payment.update(status: 'canceled') }.not_to change(CreditMutation, :count) }
      it { expect { payment.update(status: 'expired') }.not_to change(CreditMutation, :count) }
    end

    context 'when updating already paid payment' do
      subject(:payment) { create(:payment, user:, amount: 22.00, status: 'paid') }

      before do
        payment.update(status: 'paid')
      end

      it { expect(user.credit_mutations.where(description: 'iDEAL inleg').where(amount: 22.00).count).to eq 1 }
    end
  end

  describe '#update' do
    context 'when concurrently updating payment to paid' do
      subject(:payment) { create(:payment, amount: 22.00, status: 'open') }

      let(:concurrent_payment) { described_class.last }

      before do
        # Create payment and get concurrent payment
        payment
        concurrent_payment

        # Update payment after getting concurrent payment
        payment.update(status: 'paid')
      end

      it { expect { concurrent_payment.update(status: 'paid') }.to raise_error(ActiveRecord::StaleObjectError) }
    end
  end
end
