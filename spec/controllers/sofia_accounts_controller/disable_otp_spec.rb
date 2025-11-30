require 'rails_helper'

describe SofiaAccountsController do
  describe 'PATCH disable_otp' do
    let(:sofia_account) do
      create(:sofia_account, otp_enabled: true)
    end
    let(:request) do
      patch :disable_otp, params: { id: sofia_account.id }
    end

    describe 'when as sofia_account owner' do
      before do
        sign_in sofia_account.user
        request
        sofia_account.reload
      end

      it 'updates sofia_account' do
        expect(request.status).to eq 302
        expect(sofia_account.otp_enabled).to be false
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
        expect(sofia_account.otp_enabled).to be true
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
        expect(sofia_account.otp_enabled).to be true
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
        expect(sofia_account.otp_enabled).to be true
      end
    end
  end
end
