require 'rails_helper'

describe OrdersController, type: :controller do
  describe 'PUT update' do
    let(:activity) { create(:activity) }
    let(:locked_activity) { create(:activity) }
    let(:order) do
      create(:order, activity:, user: create(:user))
    end
    let(:order_on_locked_activity) do
      create(:order, activity: locked_activity, user: create(:user))
    end
    let(:products) { activity.price_list.products.sample(2) }
    let(:request) do
      put :update, params: { id: order.id, order_rows_attributes: [{ id: order.order_rows.first.id, product_count: 3 }] }
    end
    let(:request_on_locked_activity) do
      put :update,
          params: { id: order_on_locked_activity.id,
                    order_rows_attributes: [{ id: order_on_locked_activity.order_rows.first.id, product_count: 3 }] }
    end

    before do
      create(:order_row, order:, product_count: 2, product: activity.price_list.products.first)
      create(:order_row, order: order_on_locked_activity, product_count: 2, product: locked_activity.price_list.products.first)
      locked_activity.update(locked_by: create(:user))

      sign_in user
    end

    describe 'when without permission' do
      let(:user) { create(:user) }

      it 'when with order on activity' do
        request
        expect(request.status).to eq 403
        expect(Order.first.order_rows.first.product_count).to eq 2
      end

      it 'when with order on locked activty' do
        request_on_locked_activity
        expect(request_on_locked_activity.status).to eq 403
        expect(Order.first.order_rows.first.product_count).to eq 2
      end
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }

      it 'when with order on activity' do
        request
        expect(request.status).to eq 200
        expect(Order.first.order_rows.first.product_count).to eq 3
      end

      it 'when with order on locked activity' do
        request_on_locked_activity
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Order.first.order_rows.last.product_count).to eq 2
      end
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      it 'when with order on activity' do
        request
        expect(request.status).to eq 200
        expect(Order.first.order_rows.first.product_count).to eq 3
      end

      it 'when with order on locked activity' do
        request_on_locked_activity
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Order.first.order_rows.last.product_count).to eq 2
      end
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it 'when with order on activity' do
        request
        expect(request.status).to eq 200
        expect(Order.first.order_rows.first.product_count).to eq 3
      end

      it 'when with order on locked activity' do
        request_on_locked_activity
        expect(response).to have_http_status(:unprocessable_entity)
        expect(Order.first.order_rows.last.product_count).to eq 2
      end
    end
  end
end
