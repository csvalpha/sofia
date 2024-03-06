require 'rails_helper'

describe OrdersController, type: :controller do
  describe 'POST create' do
    let(:activity) { create(:activity) }
    let(:locked_activity) { create(:activity) }
    let(:order) do
      build(:order, activity: activity, user: create(:user))
    end
    let(:order_on_locked_activity) do
      build(:order, activity: locked_activity, user: create(:user))
    end
    let(:request) do
      post :create, params: { order: order.attributes }
    end
    let(:request_on_locked_activity) do
      post :create, params: { order: order_on_locked_activity.attributes }
    end

    before do
      locked_activity.update(locked_by: create(:user))

      sign_in user
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it 'when with order on activity' do
        expect { request }.to(change(Order, :count).by(1))
      end

      it 'when with order on locked activty' do
        expect { request_on_locked_activity }.not_to change(Order, :count)
      end
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }
      
      it 'when with order on activity' do
        expect { request }.to(change(Order, :count).by(1))
      end

      it 'when with order on locked activty' do
        expect { request_on_locked_activity }.not_to change(Order, :count)
      end
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }
      
      it 'when with order on activity' do
        expect { request }.to(change(Order, :count).by(1))
      end

      it 'when with order on locked activty' do
        expect { request_on_locked_activity }.not_to change(Order, :count)
      end
    end

    describe 'when as user' do
      let(:user) { create(:user) }
      
      it 'when with order on activity' do
        expect { request }.not_to change(Order, :count)
      end

      it 'when with order on locked activty' do
        expect { request_on_locked_activity }.not_to change(Order, :count)
      end
    end
  end
end
