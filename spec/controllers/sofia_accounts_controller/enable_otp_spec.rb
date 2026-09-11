require 'rails_helper'

describe SofiaAccountsController do
  describe 'PATCH enable_otp' do
    let(:sofia_account) do
      create(:sofia_account)
    end
    let(:user) { sofia_account.user }
    let(:request_params) do
      {
        id: sofia_account.id,
        verification_code: sofia_account.otp_code
      }
    end
    let(:perform_request) do
      patch :enable_otp, params: request_params
    end

    describe 'when as sofia_account owner' do
      before do
        sign_in user
        perform_request
        sofia_account.reload
      end

      it 'updates sofia_account' do
        expect(response).to have_http_status :found
        expect(sofia_account.otp_enabled).to be true
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
        expect(sofia_account.otp_enabled).to be false
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
        expect(sofia_account.otp_enabled).to be false
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
        expect(sofia_account.otp_enabled).to be false
      end
    end

    describe 'without verification_code' do
      before do
        request_params[:verification_code] = nil
        sign_in user
        perform_request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(response).to have_http_status :found
        expect(sofia_account.otp_enabled).to be false
        expect(flash[:error]).to match(/de verificatie token is niet aanwezig/)
      end
    end

    describe 'with wrong verification_code' do
      before do
        request_params[:verification_code] = SecureRandom.urlsafe_base64
        sign_in user
        perform_request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(response).to have_http_status :found
        expect(sofia_account.otp_enabled).to be false
        expect(flash[:error]).to match(/de verificatie token is ongeldig/)
      end
    end
  end
end
