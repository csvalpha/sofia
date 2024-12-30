require 'rails_helper'

describe PriceListsController, type: :controller do
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
end
