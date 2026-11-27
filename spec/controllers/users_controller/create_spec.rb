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

    context 'with a birthday' do
      let(:user) { build(:user, :sofia_account, birthday: Date.new(2000, 5, 17)) }

      it 'stores the birthday' do
        sign_in create(:user, :treasurer)
        request
        expect(User.last.birthday).to eq Date.new(2000, 5, 17)
      end
    end

    context 'with a birthday in the future' do
      let(:user) { build(:user, :sofia_account, birthday: 1.day.from_now.to_date) }

      it 'does not create the user' do
        sign_in create(:user, :treasurer)
        expect { request }.not_to change(User, :count)
        expect(flash[:error]).to include 'Birthday'
      end
    end
  end
end
