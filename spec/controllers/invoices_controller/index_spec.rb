require 'rails_helper'

describe InvoicesController do
  describe 'GET index' do
    let(:invoices) { create_list(:invoice, 2) }

    before do
      invoices
    end

    context 'when as treasurer' do
      it 'shows invoices' do
        sign_in create(:user, :treasurer)
        get :index

        expect(assigns(:invoices).size).to eq invoices.size
      end
    end

    context 'when as renting-manager' do
      it 'shows invoices' do
        sign_in create(:user, :renting_manager)
        get :index

        expect(assigns(:invoices).size).to eq invoices.size
      end
    end

    context 'when as main-bartender' do
      it 'forbids' do
        sign_in create(:user, :main_bartender)
        get :index

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when as user' do
      it 'forbids' do
        sign_in create(:user)
        get :index

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
