require 'rails_helper'

describe UsersController do
  describe 'PUT update' do
    let(:user) do
      create(:user, :manual)
    end
    let(:request) do
      put :update, params: { id: user.id, user: user.attributes }
    end

    before do
      sign_in action_user
      user.name = 'New Name'
      user.sub_provider = 'NEW_PROVIDER'
      user.birthday = Date.new(2000, 5, 17)
      request
      user.reload
    end

    describe 'when as user themselves' do
      let(:action_user) { user }

      it { expect(request.status).to eq 403 }
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

      it { expect(request.status).to eq 302 }
      it { expect(user.name).to eq 'New Name' }
      it { expect(user.sub_provider).to eq 'NEW_PROVIDER' }
      it { expect(user.birthday).to eq Date.new(2000, 5, 17) }
    end

    describe 'when as treasurer updating an amber user' do
      let(:user) { create(:user, :from_amber, birthday: Date.new(1999, 1, 1)) }
      let(:action_user) { create(:user, :treasurer) }

      it { expect(request.status).to eq 302 }
      it { expect(user.birthday).to eq Date.new(1999, 1, 1) }
    end
  end
end
