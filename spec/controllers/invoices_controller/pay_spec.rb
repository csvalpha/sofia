require 'rails_helper'

describe InvoicesController, type: :controller do
  describe 'GET /:id/pay' do
    let(:invoice) { FactoryBot.create(:invoice, :with_rows) }

    let(:request) do
      get :pay, params: { id: invoice.id }
    end

    it 'creates a new payment with current user' do
      expect { request }.to(change(Payment, :count).by(1))
      expect(Payment.last.invoice).to eq invoice
    end
  end
end
