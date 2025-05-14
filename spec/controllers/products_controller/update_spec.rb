require 'rails_helper'

describe ProductsController do
  describe 'PUT update' do
    let(:product) do
      create(:product, product_prices: [create(:product_price)])
    end
    let(:request) do
      put :update,
          params: { id: product.id,
                    product: product.attributes.merge({ product_prices_attributes: [product.product_prices.first.attributes] }) }
    end

    before do
      sign_in user
      product.product_prices.first.price = 10.00
      request
      product.reload
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

      it { expect(request.status).to eq 200 }
      it { expect(product.product_prices.first.price).to eq 10.00 }
    end
  end
end
