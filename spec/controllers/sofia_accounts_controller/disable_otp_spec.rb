require 'rails_helper'

describe SofiaAccountsController do
  describe 'PATCH disable_otp' do
    let(:sofia_account) do
      create(:sofia_account, otp_enabled: true)
    end
    let(:perform_request) do
      patch :disable_otp, params: { id: sofia_account.id }
    end

    describe 'when as sofia_account owner' do
      before do
        sign_in sofia_account.user
        perform_request
        sofia_account.reload
      end

      it 'updates sofia_account' do
        expect(response).to have_http_status :found
        expect(response).to redirect_to(user_path(sofia_account.user))
        expect(sofia_account.otp_enabled).to be false
      end
    end

    describe 'when as other user' do
      before do
        sign_in create(:user)
        perform_request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(response).to have_http_status :forbidden
        expect(sofia_account.otp_enabled).to be true
      end
    end

    describe 'when as main-bartender' do
      before do
        sign_in create(:user, :main_bartender)
        perform_request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(response).to have_http_status :forbidden
        expect(sofia_account.otp_enabled).to be true
      end
    end

    describe 'when as treasurer' do
      before do
        sign_in create(:user, :treasurer)
        perform_request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(response).to have_http_status :forbidden
        expect(sofia_account.otp_enabled).to be true
      end
    end
  end
end
