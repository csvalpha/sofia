require 'rails_helper'

describe UsersController do
  describe 'PATCH update_with_sofia_account' do
    context 'when the user already has a Sofia account' do
      let(:user) { create(:user, name: 'Old name') }
      let!(:sofia_account) { create(:sofia_account, user:, username: 'Old username') }
      let(:request_params) do
        {
          id: user.id,
          user: {
            name: 'New name',
            sofia_account_attributes: { id: sofia_account.id, username: 'New username' }
          }
        }
      end
      let(:request) do
        patch :update_with_sofia_account, params: request_params
        response
      end

      before do
        sign_in action_user
        request
        user.reload
        sofia_account.reload
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

    context 'when the user has no Sofia account yet' do
      let(:user) { create(:user) }
      let(:action_user) { user }

      before do
        sign_in action_user
        patch :update_with_sofia_account,
              params: { id: user.id, user: { sofia_account_attributes: { username: 'New username' } } }
        user.reload
      end

      it 'redirects back with an alert' do
        expect(response).to redirect_to(user)
        expect(flash[:alert]).to eq('Nog geen Sofia-account geactiveerd.')
      end

      it 'does not create a Sofia account' do
        expect(user.sofia_account).to be_nil
      end
    end
  end
end
