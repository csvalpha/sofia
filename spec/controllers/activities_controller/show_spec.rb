require 'rails_helper'

describe ActivitiesController do
  describe 'GET show' do
    render_views

    let(:activity) { create(:activity) }
    let(:order_time) { Time.zone.local(2024, 3, 5, 14, 30) }
    let!(:order) { create(:order, activity:, created_at: order_time) }

    before { sign_in user }

    context 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it 'shows the date and time of orders in the orders tab' do
        get :show, params: { id: activity.id }

        expect(response.status).to eq 200
        expect(response.body).to include('05-03-24 14:30')
      end
    end
  end
end
