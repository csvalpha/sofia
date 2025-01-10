require 'rails_helper'

describe UsersController, type: :controller do
  describe 'GET index' do
    let(:alice) { create(:user, :treasurer, :manual) }
    let(:bob) { create(:user, :renting_manager, :manual) }
    let(:carl) { create(:user, :main_bartender, :manual) }
    let(:eve) { create(:user, :manual) }

    before do
      create(:user, :from_amber)
      create(:user, :sofia_account)
      active_sofia_account_user = create(:user, :sofia_account)
      create(:sofia_account, user: active_sofia_account_user)
      create(:user, :manual, deactivated: true)
      alice
      bob
      carl
      eve
    end

    context 'when as treasurer' do
      before do
        sign_in carl
        get :index
      end

      it 'shows all users' do
        expect(assigns(:manual_users).size).to eq 4
        expect(assigns(:amber_users).size).to eq 1
        expect(assigns(:sofia_account_users).size).to eq 1
        expect(assigns(:not_activated_users).size).to eq 1
        expect(assigns(:deactivated_users).size).to eq 1
      end
    end

    context 'when as renting-manager' do
      before do
        sign_in bob
        get :index
      end

      it 'shows manual users' do
        expect(assigns(:manual_users).size).to eq 4
        expect(assigns(:amber_users).size).to eq 0
        expect(assigns(:sofia_account_users).size).to eq 0
        expect(assigns(:not_activated_users).size).to eq 0
        expect(assigns(:deactivated_users).size).to eq 1
      end
    end

    context 'when as main-bartender' do
      before do
        sign_in carl
        get :index
      end

      it 'shows own user' do
        expect(assigns(:manual_users).size).to eq 1
        expect(assigns(:amber_users).size).to eq 0
        expect(assigns(:sofia_account_users).size).to eq 0
        expect(assigns(:not_activated_users).size).to eq 0
        expect(assigns(:deactivated_users).size).to eq 0
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
