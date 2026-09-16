require 'rails_helper'

describe ProductPricesController do
  describe 'PATCH reorder' do
    let(:price_list) { create(:price_list) }
    let!(:first_product_price) { create(:product_price, price_list:, position: 0) }
    let!(:second_product_price) { create(:product_price, price_list:, position: 1) }
    let(:product_positions) do
      [{ id: first_product_price.id, position: 1, folder_id: nil }, { id: second_product_price.id, position: 0, folder_id: nil }]
    end
    let(:request) do
      patch :reorder, params: { price_list_id: price_list.id, product_positions: }
    end

    before { sign_in user }

    describe 'when without permission' do
      let(:user) { create(:user) }

      it 'does not change positions' do
        request
        expect(response).to have_http_status :forbidden
        expect(first_product_price.reload.position).to eq 0
        expect(second_product_price.reload.position).to eq 1
      end
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      it 'returns forbidden' do
        request
        expect(response).to have_http_status :forbidden
      end
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it 'updates the positions' do
        request
        expect(response).to have_http_status :ok
        expect(first_product_price.reload.position).to eq 1
        expect(second_product_price.reload.position).to eq 0
      end

      context 'when assigning a folder from the same price_list' do
        let(:folder) { create(:product_price_folder, price_list:) }
        let(:product_positions) do
          [{ id: first_product_price.id, position: 0, folder_id: folder.id }]
        end

        it 'assigns the folder' do
          request
          expect(response).to have_http_status :ok
          expect(first_product_price.reload.product_price_folder_id).to eq folder.id
        end
      end

      context 'when assigning a folder from a different price_list' do
        let(:other_folder) { create(:product_price_folder) }
        let(:product_positions) do
          [{ id: first_product_price.id, position: 0, folder_id: other_folder.id }]
        end

        it 'returns unprocessable_content and does not change the product' do
          request
          expect(response).to have_http_status(:unprocessable_content)
          expect(first_product_price.reload.product_price_folder_id).to be_nil
          expect(first_product_price.position).to eq 0
        end
      end
    end
  end
end
