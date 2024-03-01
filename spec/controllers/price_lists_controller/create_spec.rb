require 'rails_helper'

describe PriceListsController, type: :controller do
  describe 'POST create' do
    let(:price_list) do
      build(:price_list)
    end
    let(:request) do
      post :create, params: { price_list: price_list.attributes }
    end

    it 'treasurer cna create a new price_list' do
      sign_in create(:user, :treasurer)
      expect { request }.to(change(PriceList, :count).by(1))
    end

    it 'renting-manager cannot create a new price_list' do
      sign_in create(:user, :renting_manager)
      expect { request }.not_to change(PriceList, :count)
    end

    it 'main-bartender cannot create a new price_list' do
      sign_in create(:user, :main_bartender)
      expect { request }.not_to change(PriceList, :count)
    end

    it 'user cannot create a new price_list' do
      sign_in create(:user)
      expect { request }.not_to change(PriceList, :count)
    end

    it 'redirects after create' do
      sign_in create(:user, :treasurer)
      request
      expect(response).to be_redirect
    end
  end
end
