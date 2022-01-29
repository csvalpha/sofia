require 'rails_helper'

describe OrdersController, type: :controller do
  describe 'GET index' do
    let(:alice) { create(:user, :treasurer) }
    let(:eve) { create(:user) }

    let(:orders_alice) { create_list(:order, 2, user: alice) }
    let(:orders_eve) { create_list(:order, 2, user: eve) }

    before do
      orders_alice
      orders_eve
    end

    context 'when as treasurer' do
      it 'shows own orders' do
        sign_in alice
        get :index, params: { user_id: alice.id, format: :json }

        expect(Order.where(user: alice)).to match_array assigns(:orders)
      end

      it 'show other users orders' do
        sign_in alice
        get :index, params: { user_id: eve.id, format: :json }

        expect(Order.where(user: eve)).to match_array assigns(:orders)
      end
    end

    context 'when as normal user' do
      it 'shows own orders' do
        sign_in eve
        get :index, params: { user_id: eve.id, format: :json }

        expect(Order.where(user: eve)).to match_array assigns(:orders)
      end

      it 'user cannot see other users orders' do
        sign_in eve
        get :index, params: { user_id: alice.id, format: :json }

        expect(assigns(:orders)).to be_empty
      end
    end
  end
end
