require 'rails_helper'

describe UsersController do
  describe 'POST create' do
    let(:user) do
      build(:user, :manual)
    end
    let(:request) do
      post :create, params: { user: user.attributes }
    end

    it 'treasurer can create a new user' do
      sign_in create(:user, :treasurer)
      expect { request }.to(change(User, :count).by(1))
    end

    it 'renting-manager cannot create a new user' do
      sign_in create(:user, :renting_manager)
      expect { request }.not_to change(User, :count)
    end

    it 'main-bartender cannot create a new user' do
      sign_in create(:user, :main_bartender)
      expect { request }.not_to change(User, :count)
    end

    it 'user cannot create a new user' do
      sign_in create(:user)
      expect { request }.not_to change(User, :count)
    end

    it 'redirects after create' do
      sign_in create(:user, :treasurer)
      request
      expect(response).to be_redirect
    end
  end
end
