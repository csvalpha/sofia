require 'rails_helper'

describe PaymentsController do
  describe 'POST create' do
    let(:user) { create(:user) }
    let(:eve) { create(:user) }
    let(:payment) do
      build(:payment, user: eve)
    end
    let(:request) do
      post :create, params: { payment: payment.attributes }
    end

    let(:mollie) { instance_double(Mollie::Payment) }

    before do
      allow(Mollie::Payment).to receive_messages(create: mollie, get: mollie)
      allow(mollie).to receive_messages(id: 1, checkout_url: 'https://example.com')
    end

    context 'when with incorrect amount' do
      let(:payment) do
        build(:payment, amount: 0)
      end

      it 'creates does not create an payment' do
        sign_in user
        expect { request }.not_to change(Payment, :count)
      end
    end

    context 'when with correct amount' do
      it 'creates a new payment with current user' do
        sign_in user
        expect { request }.to(change(Payment, :count).by(1))
        expect(Payment.last.user).to eq user
      end
    end
  end
end
