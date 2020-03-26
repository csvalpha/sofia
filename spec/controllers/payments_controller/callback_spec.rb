# rubocop:disable RSpec/AnyInstance
require 'rails_helper'

describe PaymentsController, type: :controller do
  describe 'GET callback' do
    let(:user) { FactoryBot.create(:user) }
    let(:payment) do
      FactoryBot.build(:payment)
    end

    describe 'handles paid payment' do
      let(:payment) { FactoryBot.create(:payment, status: 'open', user: user, amount: '22.00') }
      let(:request) { get :callback, params: { id: payment.id } }

      let(:mollie) { instance_double(Mollie::Payment) }
      let(:amount) { instance_double(Mollie::Amount) }

      before do
        allow_any_instance_of(Payment).to receive(:mollie_payment).and_return(mollie)
        allow(mollie).to receive(:status).and_return(:paid)
        allow(mollie).to receive(:paid?).and_return(true)
        allow(mollie).to receive(:amount).and_return(amount)
        allow(amount).to receive(:value).and_return(22.00)

        request
        payment.reload
      end

      it { expect(payment.status).to eq 'paid' }
      it { expect(user.credit_mutations.last.description).to eq 'iDEAL inleg' }
      it { expect(user.credit_mutations.last.amount).to eq 22.00 }
    end

    describe 'handles open payment' do
      let(:payment) { FactoryBot.create(:payment, status: 'open', user: user, amount: '22.00') }
      let(:request) { get :callback, params: { id: payment.id } }

      let(:mollie) { instance_double(Mollie::Payment) }
      let(:amount) { instance_double(Mollie::Amount) }

      before do
        allow_any_instance_of(Payment).to receive(:mollie_payment).and_return(mollie)
        allow(mollie).to receive(:status).and_return(:open)
        allow(mollie).to receive(:paid?).and_return(false)
        allow(mollie).to receive(:amount).and_return(amount)
        allow(amount).to receive(:value).and_return(22.00)

        request
        payment.reload
      end

      it { expect(payment.status).to eq 'open' }
      it { expect(user.credit_mutations.count).to eq 0 }
    end

    describe 'handles already paid payment' do
      let(:payment) { FactoryBot.create(:payment, status: 'paid', user: user, amount: '22.00') }
      let(:request) { get :callback, params: { id: payment.id } }

      let(:mollie) { instance_double(Mollie::Payment) }
      let(:amount) { instance_double(Mollie::Amount) }

      before do
        allow_any_instance_of(Payment).to receive(:mollie_payment).and_return(mollie)
        allow(mollie).to receive(:status).and_return(:paid)
        allow(mollie).to receive(:paid?).and_return(true)
        allow(mollie).to receive(:amount).and_return(amount)
        allow(amount).to receive(:value).and_return(22.00)

        request
        payment.reload
      end

      it { expect(payment.status).to eq 'paid' }
      it { expect(user.credit_mutations.count).to eq 0 }
    end
  end
end
# rubocop:enable RSpec/AnyInstance
