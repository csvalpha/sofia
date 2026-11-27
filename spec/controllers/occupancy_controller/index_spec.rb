require 'rails_helper'

describe OccupancyController do
  describe 'GET index' do
    before do
      allow(Rails.application.config.x).to receive(:occupancy_api_token).and_return(token)
      allow(BarOccupancy).to receive(:current).and_return({ status: 'open', count: 12 })
    end

    let(:token) { 'secret' }

    context 'when logged in' do
      before { sign_in create(:user) }

      it 'returns the occupancy' do
        get :index

        expect(response).to have_http_status :ok
        expect(response.parsed_body).to eq('status' => 'open', 'count' => 12)
      end

      context 'without a configured token' do
        let(:token) { nil }

        it 'is forbidden' do
          get :index

          expect(response).to have_http_status :forbidden
        end
      end
    end

    context 'when logged out' do
      it 'is unauthorized' do
        get :index, format: :json

        expect(response).to have_http_status :unauthorized
        expect(BarOccupancy).not_to have_received(:current)
      end
    end
  end
end
