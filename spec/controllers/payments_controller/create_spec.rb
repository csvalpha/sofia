require 'rails_helper'

describe PaymentsController, type: :controller do
  describe 'POST create' do
    let(:user) { FactoryBot.create(:user) }
    let(:eve) { FactoryBot.create(:user) }
    let(:payment) do
      FactoryBot.build(:payment, user: eve)
    end
    let(:request) do
      post :create, params: { payment: payment.attributes }
    end

    let(:mollie) { instance_double(Mollie::Payment) }

    before do
      allow(Mollie::Payment).to receive(:create).and_return(mollie)
      allow(Mollie::Payment).to receive(:get).and_return(mollie)
      allow(mollie).to receive(:id).and_return(1)
      allow(mollie).to receive(:checkout_url).and_return('https://example.com')
    end

    context 'when with incorrect amount' do
      let(:payment) do
        FactoryBot.build(:payment, amount: 0)
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
