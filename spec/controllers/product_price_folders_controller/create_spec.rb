require 'rails_helper'

describe ProductPriceFoldersController do
  describe 'POST create' do
    let(:price_list) { create(:price_list) }
    let(:folder_params) { { name: 'Beers', color: '#FF5733' } }
    let(:request) do
      post :create, params: { price_list_id: price_list.id, product_price_folder: folder_params }
    end

    before { sign_in user }

    describe 'when without permission' do
      let(:user) { create(:user) }

      it { expect { request }.not_to change(ProductPriceFolder, :count) }

      it 'returns forbidden' do
        request
        expect(response).to have_http_status :forbidden
      end
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      it { expect { request }.not_to change(ProductPriceFolder, :count) }
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }

      it { expect { request }.not_to change(ProductPriceFolder, :count) }
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it { expect { request }.to change(ProductPriceFolder, :count).by(1) }

      it 'creates the folder on the given price_list' do
        request
        expect(ProductPriceFolder.last.price_list).to eq price_list
      end

      it 'returns the created folder' do
        request
        expect(response).to have_http_status :created
        expect(response.parsed_body['name']).to eq 'Beers'
      end

      context 'with invalid attributes' do
        let(:folder_params) { { name: '', color: '#FF5733' } }

        it { expect { request }.not_to change(ProductPriceFolder, :count) }

        it 'returns unprocessable_content with errors' do
          request
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body['errors']).to be_present
        end
      end
    end
  end
end
