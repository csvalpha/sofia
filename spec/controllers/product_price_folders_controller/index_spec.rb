require 'rails_helper'

describe ProductPriceFoldersController do
  describe 'GET index' do
    let(:price_list) { create(:price_list) }
    let!(:folder) { create(:product_price_folder, price_list:) }
    let(:request) do
      get :index, params: { price_list_id: price_list.id }
    end

    before { sign_in user }

    describe 'when without permission' do
      let(:user) { create(:user) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it { expect(request.status).to eq 200 }
      it { expect(request.parsed_body.pluck('id')).to eq [folder.id] }
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      it { expect(request.status).to eq 200 }
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }

      it { expect(request.status).to eq 200 }
    end
  end
end
