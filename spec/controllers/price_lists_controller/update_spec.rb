require 'rails_helper'

describe PriceListsController do
  describe 'PUT update' do
    let(:price_list) do
      create(:price_list)
    end
    let(:request) do
      put :update, params: { id: price_list.id, price_list: price_list.attributes }
    end

    before do
      sign_in user
      price_list.name = 'New Name'
      request
      price_list.reload
    end

    describe 'when without permission' do
      let(:user) { create(:user) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it { expect(request.status).to eq 302 }
      it { expect(price_list.name).to eq 'New Name' }
    end
  end

  describe 'PATCH update as json' do
    let(:price_list) { create(:price_list) }
    let(:user) { create(:user, :treasurer) }

    before { sign_in user }

    it 'updates the grid size without redirecting' do
      patch :update, params: { id: price_list.id, price_list: { grid_size: 6 } }, format: :json
      expect(response.status).to eq 200
      expect(response.parsed_body['grid_size']).to eq 6
      expect(price_list.reload.grid_size).to eq 6
      expect(flash).to be_empty
    end

    it 'returns errors for an invalid grid size' do
      patch :update, params: { id: price_list.id, price_list: { grid_size: 12 } }, format: :json
      expect(response.status).to eq 422
      expect(price_list.reload.grid_size).not_to eq 12
    end
  end
end
