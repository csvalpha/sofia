require 'rails_helper'

describe PaymentsController, type: :controller do
  describe 'GET index' do
    let(:payments) { create_list(:payment, 2) }

    before do
      payments
    end

    context 'when as treasurer' do
      it 'shows payment' do
        sign_in create(:user, :treasurer)
        get :index

        expect(assigns(:payments).size).to eq payments.size
      end
    end

    context 'when as renting-manager' do
      it 'forbids' do
        sign_in create(:user, :renting_manager)
        get :index

        expect(response).to have_http_status(:forbidden)
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
