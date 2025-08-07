require 'rails_helper'

describe OrdersController do
  describe 'GET index' do
    let(:alice) { create(:user, :treasurer) }
    let(:bob) { create(:user, :renting_manager) }
    let(:carl) { create(:user, :main_bartender) }
    let(:amber) { create(:user, :from_amber) }
    let(:eve) { create(:user) }

    let(:orders_alice) { create_list(:order, 2, user: alice) }
    let(:orders_amber) { create_list(:order, 2, user: amber) }
    let(:orders_eve) { create_list(:order, 2, user: eve) }

    before do
      orders_alice
      orders_amber
      orders_eve
    end

    context 'when as treasurer' do
      it 'shows own orders' do
        sign_in alice
        get :index, params: { user_id: alice.id, format: :json }

        expect(Order.where(user: alice)).to match_array assigns(:orders)
      end

      it 'show other manual users orders' do
        sign_in alice
        get :index, params: { user_id: eve.id, format: :json }

        expect(Order.where(user: eve)).to match_array assigns(:orders)
      end

      it 'shows other amber users orders' do
        sign_in alice
        get :index, params: { user_id: amber.id, format: :json }

        expect(Order.where(user: amber)).to match_array assigns(:orders)
      end
    end

    context 'when as renting-manager' do
      it 'shows own orders' do
        sign_in bob
        get :index, params: { user_id: bob.id, format: :json }

        expect(Order.where(user: bob)).to match_array assigns(:orders)
      end

      it 'shows other manual users orders' do
        sign_in bob
        get :index, params: { user_id: eve.id, format: :json }

        expect(Order.where(user: eve)).to match_array assigns(:orders)
      end

      it 'shows other amber users orders' do
        sign_in bob
        get :index, params: { user_id: amber.id, format: :json }

        expect(Order.where(user: amber)).to match_array assigns(:orders)
      end
    end

    context 'when as main-bartender' do
      it 'shows own orders' do
        sign_in carl
        get :index, params: { user_id: carl.id, format: :json }

        expect(Order.where(user: carl)).to match_array assigns(:orders)
      end

      it 'shows other manual users orders' do
        sign_in carl
        get :index, params: { user_id: eve.id, format: :json }

        expect(Order.where(user: eve)).to match_array assigns(:orders)
      end

      it 'shows other amber users orders' do
        sign_in carl
        get :index, params: { user_id: amber.id, format: :json }

        expect(Order.where(user: amber)).to match_array assigns(:orders)
      end
    end

    context 'when as normal user' do
      it 'shows own orders' do
        sign_in eve
        get :index, params: { user_id: eve.id, format: :json }

        expect(Order.where(user: eve)).to match_array assigns(:orders)
      end

      it 'user cannot see other manual users orders' do
        sign_in eve
        get :index, params: { user_id: alice.id, format: :json }

        expect(assigns(:orders)).to be_empty
      end

      it 'user cannot see other amber users orders' do
        sign_in eve
        get :index, params: { user_id: amber.id, format: :json }

        expect(assigns(:orders)).to be_empty
      end
    end
  end
end
