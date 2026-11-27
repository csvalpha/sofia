require 'rails_helper'

describe ProductPriceFoldersController do
  describe 'PATCH reorder' do
    let(:price_list) { create(:price_list) }
    let!(:first_folder) { create(:product_price_folder, price_list:, position: 0) }
    let!(:second_folder) { create(:product_price_folder, price_list:, position: 1) }
    let(:folder_positions) do
      [{ id: first_folder.id, position: 1 }, { id: second_folder.id, position: 0 }]
    end
    let(:request) do
      patch :reorder, params: { price_list_id: price_list.id, folder_positions: }
    end

    before { sign_in user }

    describe 'when without permission' do
      let(:user) { create(:user) }

      it 'does not change positions' do
        request
        expect(response).to have_http_status :forbidden
        expect(first_folder.reload.position).to eq 0
        expect(second_folder.reload.position).to eq 1
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
        expect(first_folder.reload.position).to eq 1
        expect(second_folder.reload.position).to eq 0
      end

      context 'with invalid position data' do
        let(:folder_positions) do
          [{ id: first_folder.id, position: nil }]
        end

        it 'returns unprocessable_content and rolls back changes' do
          request
          expect(response).to have_http_status(:unprocessable_content)
          expect(first_folder.reload.position).to eq 0
        end
      end
    end
  end
end
