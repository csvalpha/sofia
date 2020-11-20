require 'rails_helper'

describe PaymentDoneJob, type: :job do
  describe '#perform' do
    let(:emails) { ActionMailer::Base.deliveries }

    subject(:job) { perform_enqueued_jobs { described_class.perform_now(payment) } }

    context 'When for user' do
      let(:user) { FactoryBot.create(:user) }
      let(:payment) { FactoryBot.create(:payment, user: user, amount: 22) }

      before do
        ActionMailer::Base.deliveries = []
        job
      end

      it { expect(payment.status).to eq 'paid' }
      it { expect(user.credit_mutations.last.description).to eq 'iDEAL inleg' }
      it { expect(user.credit_mutations.last.amount).to eq 22.00 }
      it { expect(emails.last.subject).to eq "Je saldo is bijgewerkt" }
    end

    context "When for invoice" do
      let(:invoice) { FactoryBot.create(:invoice) }
      let(:payment) { FactoryBot.create(:payment, user: nil, invoice: invoice, amount: invoice.amount) }

      before do
        ActionMailer::Base.deliveries = []

        invoice.save
        job
      end

      it { expect(payment.status).to eq 'paid' }
      it { expect(invoice.status).to eq 'paid' }
      it { expect(emails.last.subject).to eq "Betaalbevesting factuur #{invoice.human_id} Stichting Sociëteit Flux" }
    end
  end
end
