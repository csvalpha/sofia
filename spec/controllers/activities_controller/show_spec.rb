require 'rails_helper'

describe ActivitiesController do
  describe 'GET show' do
    render_views

    let(:activity) { create(:activity) }

    before do
      sign_in user
      # Asset helpers are unavailable in the focused test image; stub rendering only.
      allow_any_instance_of(ActionView::Base).to receive_messages( # rubocop:disable RSpec/AnyInstance
        javascript_include_tag: '',
        stylesheet_link_tag: ''
      )
    end

    context 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it 'shows the date and time of orders in the orders tab' do
        create(:order, :cash, activity:, created_at: Time.zone.local(2024, 3, 5, 14, 30))
        get :show, params: { id: activity.id }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('05-03-24 14:30')
      end
    end
  end
end
