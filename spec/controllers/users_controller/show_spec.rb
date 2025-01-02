require 'rails_helper'

describe UsersController, type: :controller do
  describe 'GET show' do
    let(:amber) { create(:user, :from_amber) }
    let(:eve) { create(:user, :manual) }

    before do
      amber
      eve
    end

    context 'when as treasurer' do
      it 'shows manual user' do
        sign_in create(:user, :treasurer)
        get :show, params: { id: eve.id }

        expect(response).to have_http_status(:ok)
      end

      it 'shows amber user' do
        sign_in create(:user, :treasurer)
        get :show, params: { id: amber.id }

        expect(response).to have_http_status(:ok)
      end
    end

    context 'when as renting-manager' do
      it 'shows manual user' do
        sign_in create(:user, :renting_manager)
        get :show, params: { id: eve.id }

        expect(response).to have_http_status(:ok)
      end

      it 'forbids showing amber user' do
        sign_in create(:user, :renting_manager)
        get :show, params: { id: amber.id }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when as main-bartender' do
      it 'forbids showing manual user' do
        sign_in create(:user, :main_bartender)
        get :show, params: { id: eve.id }

        expect(response).to have_http_status(:forbidden)
      end

      it 'forbids showing amber user' do
        sign_in create(:user, :main_bartender)
        get :show, params: { id: amber.id }

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when as user' do
      it 'forbids showing manual user' do
        sign_in create(:user)
        get :show, params: { id: eve.id }

        expect(response).to have_http_status(:forbidden)
      end

      it 'forbids showing amber user' do
        sign_in create(:user)
        get :show, params: { id: amber.id }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
