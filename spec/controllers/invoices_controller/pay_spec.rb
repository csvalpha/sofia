require 'rails_helper'

describe InvoicesController, type: :controller do
  describe 'GET /:id/pay' do
    let(:invoice) { create(:invoice, :with_rows) }
    let(:id) { invoice.id }

    let(:http_request) do
      get :pay, params: { id: }
    end

    context 'when authorized' do
      it 'creates a new payment' do
        sign_in create(:user, :treasurer)

        expect { http_request }.to(change(Payment, :count).by(1))
        expect(Payment.last.invoice).to eq invoice
      end
    end

    context 'when not authorized with id' do
      it 'forbids' do
        http_request

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when not authorized with token' do
      let(:id) { invoice.token }

      it 'creates a new payment' do
        expect { http_request }.to(change(Payment, :count).by(1))
        expect(response).to have_http_status(:found)
        expect(Payment.last.invoice).to eq invoice
      end
    end

    context 'when with already paid payment' do
      let(:invoice) { create(:invoice, :with_rows, status: :paid) }

      it 'redirects to invoice' do
        sign_in create(:user, :treasurer)

        expect(http_request).to redirect_to(invoice_url)
      end
    end
  end
end
