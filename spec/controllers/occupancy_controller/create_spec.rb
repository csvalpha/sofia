require 'rails_helper'

describe OccupancyController do
  describe 'POST create' do
    before do
      allow(Rails.application.config.x).to receive(:occupancy_api_token).and_return(token)
      allow(BarOccupancy).to receive(:record)
      request.headers['Authorization'] = "Bearer #{given_token}" if given_token
    end

    let(:token) { 'secret' }
    let(:given_token) { token }
    let(:params) { { session_active: true, current_occupancy: 12 } }
    let(:perform) { post :create, params:, as: :json }

    context 'with a valid token' do
      it 'stores the occupancy' do
        perform

        expect(response).to have_http_status :no_content
        expect(BarOccupancy).to have_received(:record).with(session_active: true, count: 12)
      end

      it 'accepts an inactive session with no people' do
        post :create, params: { session_active: false, current_occupancy: 0 }, as: :json

        expect(response).to have_http_status :no_content
        expect(BarOccupancy).to have_received(:record).with(session_active: false, count: 0)
      end

      [
        { session_active: 'true', current_occupancy: 12 },
        { session_active: true, current_occupancy: '12' },
        { session_active: true, current_occupancy: -1 },
        { session_active: true },
        { current_occupancy: 12 }
      ].each do |invalid_params|
        it "rejects #{invalid_params}" do
          post :create, params: invalid_params, as: :json

          expect(response).to have_http_status :unprocessable_content
          expect(BarOccupancy).not_to have_received(:record)
        end
      end
    end

    context 'with a wrong token' do
      let(:given_token) { 'wrong' }

      it 'is unauthorized' do
        perform

        expect(response).to have_http_status :unauthorized
        expect(BarOccupancy).not_to have_received(:record)
      end
    end

    context 'without a token' do
      let(:given_token) { nil }

      it 'is unauthorized' do
        perform

        expect(response).to have_http_status :unauthorized
        expect(BarOccupancy).not_to have_received(:record)
      end
    end

    context 'when no token is configured' do
      let(:token) { nil }
      let(:given_token) { 'anything' }

      it 'is unauthorized' do
        perform

        expect(response).to have_http_status :unauthorized
        expect(BarOccupancy).not_to have_received(:record)
      end
    end
  end
end
