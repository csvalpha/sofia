require 'rails_helper'

describe OrdersController, type: :controller do
  describe 'GET index' do
    let(:alice) { FactoryBot.create(:user, :treasurer) }
    let(:eve) { FactoryBot.create(:user) }

    let(:orders_alice) { FactoryBot.create_list(:order, 2, user: alice) }
    let(:orders_eve) { FactoryBot.create_list(:order, 2, user: eve) }

    before do
      orders_alice
      orders_eve
    end

    it 'returns all orders' do
      sign_in alice
      get :index, params: { user_id: alice.id, format: :json }

      expect(assigns(:orders)).to eq Order.where(user: alice)
    end

    it 'returns eves orders' do
      sign_in eve
      get :index, params: { user_id: alice.id, format: :json }

      expect(assigns(:orders)).to be_empty
    end
  end
end
