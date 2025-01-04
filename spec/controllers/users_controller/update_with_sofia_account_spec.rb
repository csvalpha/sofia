require 'rails_helper'

describe UsersController, type: :controller do
  describe 'PATCH update_with_sofia_account' do
    let(:user) { create(:user, :sofia_account, name: "Old name") }
    let(:sofia_account) { create(:sofia_account, user: user, username: "Old username") }
    let(:sofia_account_attributes) { {"username": "AAAA"} }
    let(:request) do
      patch :update_with_sofia_account, params: { id: user.id, user: user.attributes.merge({ "sofia_account_attributes": sofia_account.attributes }) }
    end

    before do
      user
      sofia_account
      sign_in action_user
      user.sofia_account.username = "New username"
      user.name = "New name"
      request
      user.reload
    end

    describe 'when as user themselves' do
      let(:action_user) { user }

      it { expect(request.status).to eq 302 }
      it { expect(user.sofia_account.username).to eq 'New username' }
      it { expect(user.name).to eq 'Old name' }
    end

    describe 'when as another user' do
      let(:action_user) { create(:user) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as main-bartender' do
      let(:action_user) { create(:user, :main_bartender) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as renting-manager' do
      let(:action_user) { create(:user, :renting_manager) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as treasurer' do
      let(:action_user) { create(:user, :treasurer) }

      it { expect(request.status).to eq 403 }
    end
  end
end