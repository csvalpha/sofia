require 'rails_helper'

describe SofiaAccountsController, type: :controller do
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
    let(:request) do
      patch :enable_otp, params: request_params
    end

    describe 'when as sofia_account owner' do
      before do
        sign_in user
        request
        sofia_account.reload
      end

      it 'updates sofia_account' do
        expect(request.status).to eq 302
        expect(sofia_account.otp_enabled).to be true
      end
    end

    describe 'when as other user' do
      before do
        sign_in create(:user)
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(request.status).to eq 403
        expect(sofia_account.otp_enabled).to be false
      end
    end

    describe 'when as main-bartender' do
      before do
        sign_in create(:user, :main_bartender)
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(request.status).to eq 403
        expect(sofia_account.otp_enabled).to be false
      end
    end

    describe 'when as treasurer' do
      before do
        sign_in create(:user, :treasurer)
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(request.status).to eq 403
        expect(sofia_account.otp_enabled).to be false
      end
    end

    describe 'without verification_code' do
      before do
        request_params[:verification_code] = nil
        sign_in user
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(request.status).to eq 302
        expect(sofia_account.otp_enabled).to be false
        expect(flash[:error]).to match(/de verificatie token is niet aanwezig/)
      end
    end

    describe 'with wrong verication_code' do
      before do
        request_params[:verification_code] = SecureRandom.urlsafe_base64
        sign_in user
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(request.status).to eq 302
        expect(sofia_account.otp_enabled).to be false
        expect(flash[:error]).to match(/de verificatie token is ongeldig/)
      end
    end
  end
end
