require 'rails_helper'

describe ProductPriceFoldersController do
  describe 'DELETE destroy' do
    let!(:folder) { create(:product_price_folder) }
    let(:request) do
      delete :destroy, params: { id: folder.id }
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

      it { expect { request }.to change(ProductPriceFolder, :count).by(-1) }

      it 'returns no_content' do
        request
        expect(response).to have_http_status(:no_content)
      end

      context 'when the folder has product_prices' do
        let(:folder) { create(:product_price_folder, price_list: create(:price_list, :with_products, products: [])) }
        let!(:without_folder) { create(:product_price, price_list: folder.price_list, position: 0) }
        let!(:in_folder) { create(:product_price, price_list: folder.price_list, product_price_folder: folder, position: 0) }

        it 'unassigns the products from the folder and appends them after the existing ones' do
          request
          expect(in_folder.reload.product_price_folder_id).to be_nil
          expect(in_folder.position).to eq(without_folder.reload.position + 1)
        end
      end
    end
  end
end
