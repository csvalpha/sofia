require 'rails_helper'

RSpec.describe PaymentPollJob do
  describe '#perform' do
    context 'when payment has a mollie id' do
      let(:payment) { create(:payment, status: 'open') }
      let(:mollie_payment) { instance_double(Mollie::Payment, status: 'expired') }

      before do
        allow(Mollie::Payment).to receive(:get).with(payment.mollie_id).and_return(mollie_payment)
        described_class.perform_now
      end

      it { expect(payment.reload.status).to eq 'expired' }
    end

    context 'when payment without mollie id is older than 15 minutes' do
      let(:payment) { create(:payment, mollie_id: nil, status: 'open', created_at: 20.minutes.ago) }

      before do
        allow(Mollie::Payment).to receive(:get)
        payment
        described_class.perform_now
      end

      it { expect(payment.reload.status).to eq 'failed' }
      it { expect(Mollie::Payment).not_to have_received(:get) }
    end

    context 'when payment without mollie id is recent' do
      let(:payment) { create(:payment, mollie_id: nil, status: 'open', created_at: 5.minutes.ago) }

      before do
        allow(Mollie::Payment).to receive(:get)
        payment
        described_class.perform_now
      end

      it { expect(payment.reload.status).to eq 'open' }
      it { expect(Mollie::Payment).not_to have_received(:get) }
    end
  end
end
