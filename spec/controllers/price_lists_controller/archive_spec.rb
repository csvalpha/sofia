require 'rails_helper'

describe PriceListsController do
  describe 'POST /:id/archive' do
    let(:price_list) do
      create(:price_list)
    end
    let(:request) do
      post :archive, params: { id: price_list.id, format: :json }
    end

    before do
      sign_in user
      request
      price_list.reload
    end

    describe 'treasurer can archive a price_list' do
      let(:user) { create(:user, :treasurer) }

      it { expect(request.status).to eq 200 }
      it { expect(price_list.archived_at.today?).to be true }
    end

    describe 'renting-manager cannot archive a price_list' do
      let(:user) { create(:user, :renting_manager) }

      it { expect(request.status).to eq 403 }
    end

    describe 'main-bartender cannot archive a price_list' do
      let(:user) { create(:user, :main_bartender) }

      it { expect(request.status).to eq 403 }
    end

    describe 'user cannot archive a price_list' do
      let(:user) { create(:user) }

      it { expect(request.status).to eq 403 }
    end
  end
end
