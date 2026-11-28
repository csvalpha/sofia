require 'rails_helper'

describe ActivitiesController do
  describe 'GET show' do
    render_views

    let(:activity) { create(:activity) }

    before { sign_in user }

    context 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it 'shows the date and time of orders in the orders tab' do
        create(:order, :cash, activity:, created_at: Time.zone.local(2024, 3, 5, 14, 30))
        get :show, params: { id: activity.id }

        expect(response.status).to eq 200
        expect(response.body).to include('05-03-24 14:30')
      end

      it 'shows the date and time of credit mutations in the credit mutations tab' do
        create(:credit_mutation, activity:, created_at: Time.zone.local(2024, 4, 6, 15, 45))
        get :show, params: { id: activity.id }

        expect(response.status).to eq 200
        expect(response.body).to include('06-04-24 15:45')
      end
    end
  end
end
