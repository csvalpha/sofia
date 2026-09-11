require 'rails_helper'

describe ProductsController do
  describe 'POST create' do
    let(:product) do
      build(:product)
    end
    let(:request) do
      post :create, params: { product: product.attributes }
    end

    it 'treasurer can create a new product' do
      sign_in create(:user, :treasurer)
      expect { request }.to(change(Product, :count).by(1))
    end

    it 'renting-manager cannot create a new product' do
      sign_in create(:user, :renting_manager)
      expect { request }.not_to change(Product, :count)
    end

    it 'main-bartender cannot create a new product' do
      sign_in create(:user, :main_bartender)
      expect { request }.not_to change(Product, :count)
    end

    it 'user cannot create a new product' do
      sign_in create(:user)
      expect { request }.not_to change(Product, :count)
    end
  end
end
