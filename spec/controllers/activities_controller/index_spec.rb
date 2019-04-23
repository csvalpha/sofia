require 'rails_helper'

describe ActivitiesController, type: :controller do
  describe 'GET index' do
    let(:activities) { FactoryBot.create_list(:activity, 3) }
    let(:price_lists) { FactoryBot.create_list(:price_list, 3) }

    before { activities && price_lists }

    it 'assigns the values' do
      sign_in FactoryBot.create(:user, :treasurer)
      get :index
      expect(assigns(:activities).size).to eq activities.size
      expect(assigns(:price_lists_json)).to eq PriceList.all.to_json(only: %i[id name])
      expect(assigns(:activity)).to be_an_instance_of(Activity)
    end
  end
end
