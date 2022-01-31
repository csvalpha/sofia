require 'rails_helper'

describe ActivitiesController, type: :controller do
  describe 'POST create' do
    let(:activity) do
      build(:activity, price_list: create(:price_list))
    end
    let(:request) do
      post :create, params: { activity: activity.attributes }
    end

    it 'creates a new activity' do
      sign_in create(:user, :treasurer)
      expect { request }.to(change(Activity, :count).by(1))
    end

    it 'redirects after create' do
      sign_in create(:user, :treasurer)
      request
      expect(response).to be_redirect
    end
  end
end
