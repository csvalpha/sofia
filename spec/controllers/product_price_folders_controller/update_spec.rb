require 'rails_helper'

describe ProductPriceFoldersController do
  describe 'PATCH update' do
    let(:folder) { create(:product_price_folder, name: 'Old name') }
    let(:request) do
      patch :update, params: { id: folder.id, product_price_folder: { name: 'New name' } }
    end

    before { sign_in user }

    describe 'when without permission' do
      let(:user) { create(:user) }

      it 'does not update the folder' do
        request
        expect(response).to have_http_status :forbidden
        expect(folder.reload.name).to eq 'Old name'
      end
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      it 'does not update the folder' do
        request
        expect(response).to have_http_status :forbidden
        expect(folder.reload.name).to eq 'Old name'
      end
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }

      it 'does not update the folder' do
        request
        expect(response).to have_http_status :forbidden
        expect(folder.reload.name).to eq 'Old name'
      end
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it 'updates the folder' do
        request
        expect(response).to have_http_status :ok
        expect(folder.reload.name).to eq 'New name'
      end

      context 'with invalid attributes' do
        let(:request) do
          patch :update, params: { id: folder.id, product_price_folder: { name: '' } }
        end

        it 'returns unprocessable_content and does not update' do
          request
          expect(response).to have_http_status(:unprocessable_content)
          expect(folder.reload.name).to eq 'Old name'
        end
      end
    end
  end
end
