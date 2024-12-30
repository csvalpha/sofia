require 'rails_helper'

describe UsersController, type: :controller do
  describe 'GET index' do
    let(:alice) { create(:user, :treasurer, :manual) }
    let(:bob) { create(:user, :renting_manager, :manual) }
    let(:carl) { create(:user, :main_bartender, :manual) }
    let(:amber) { create(:user, :from_amber) }
    let(:eve) { create(:user, :manual) }

    before do
      alice
      bob
      carl
      amber
      eve
    end

    context 'when as treasurer' do
      it 'shows all users' do
        sign_in alice
        get :index

        expect(assigns(:manual_users).size).to eq 4
        expect(assigns(:amber_users).size).to eq 1
      end
    end

    context 'when as renting-manager' do
      it 'shows manual users' do
        sign_in bob
        get :index

        expect(assigns(:manual_users).size).to eq 4
        expect(assigns(:amber_users).size).to eq 0
      end
    end

    context 'when as main-bartender' do
      it 'shows own user' do
        sign_in carl
        get :index

        expect(assigns(:manual_users).size).to eq 1
        expect(assigns(:amber_users).size).to eq 0
      end
    end

    context 'when as user' do
      it 'forbids' do
        sign_in eve
        get :index

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
