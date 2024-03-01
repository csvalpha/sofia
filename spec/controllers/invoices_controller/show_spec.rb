require 'rails_helper'

describe InvoicesController, type: :controller do
  describe 'GET show' do
    let(:invoice) { create(:invoice) }

    before do
      invoice
    end

    context 'when as treasurer' do
      it 'shows invoice' do
        sign_in create(:user, :treasurer)
        get :show, params: { id: invoice.id }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when as renting-manager' do
      it 'shows invoice' do
        sign_in create(:user, :renting_manager)
        get :show, params: { id: invoice.id }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when as main-bartender' do
      it 'forbids' do
        sign_in create(:user)
        get :show, params: { id: invoice.id }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when as user' do
      it 'forbids' do
        sign_in create(:user)
        get :show, params: { id: invoice.id }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when as not authorized user with id' do
      it 'forbids' do
        get :show, params: { id: invoice.id }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when as not authorized user with token' do
      it 'shows invoice' do
        get :show, params: { id: invoice.token }

        expect(response).to have_http_status(:ok)
      end
    end
  end
end
