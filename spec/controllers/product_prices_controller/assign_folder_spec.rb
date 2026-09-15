require 'rails_helper'

describe ProductPricesController do
  describe 'PATCH assign_folder' do
    let(:price_list) { create(:price_list) }
    let(:folder) { create(:product_price_folder, price_list:) }
    let(:product_price) { create(:product_price, price_list:, position: 0) }
    let(:request) do
      patch :assign_folder, params: { id: product_price.id, folder_id: folder.id, position: 2 }
    end

    before { sign_in user }

    describe 'when without permission' do
      let(:user) { create(:user) }

      it 'does not assign the folder' do
        request
        expect(response).to have_http_status :forbidden
        expect(product_price.reload.product_price_folder_id).to be_nil
      end
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      it 'returns forbidden' do
        request
        expect(response).to have_http_status :forbidden
      end
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }

      it 'returns forbidden' do
        request
        expect(response).to have_http_status :forbidden
      end
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it 'assigns the folder and position' do
        request
        expect(response).to have_http_status :ok
        product_price.reload
        expect(product_price.product_price_folder_id).to eq folder.id
        expect(product_price.position).to eq 2
      end

      context 'when the folder does not exist' do
        let(:request) do
          patch :assign_folder, params: { id: product_price.id, folder_id: 0 }
        end

        it 'returns unprocessable_content with an error' do
          request
          expect(response).to have_http_status(:unprocessable_content)
          expect(response.parsed_body['errors']).to include('Folder not found')
        end
      end

      context 'when the folder belongs to a different price_list' do
        let(:other_folder) { create(:product_price_folder) }
        let(:request) do
          patch :assign_folder, params: { id: product_price.id, folder_id: other_folder.id }
        end

        it 'returns unprocessable_content and does not assign the folder' do
          request
          expect(response).to have_http_status(:unprocessable_content)
          expect(product_price.reload.product_price_folder_id).to be_nil
        end
      end

      context 'when unassigning from a folder' do
        let(:product_price) { create(:product_price, price_list:, product_price_folder: folder, position: 0) }
        let(:request) do
          patch :assign_folder, params: { id: product_price.id, folder_id: '' }
        end

        it 'clears the folder' do
          request
          expect(response).to have_http_status :ok
          expect(product_price.reload.product_price_folder_id).to be_nil
        end
      end
    end
  end
end
