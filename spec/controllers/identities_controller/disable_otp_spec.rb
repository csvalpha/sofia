require 'rails_helper'

describe IdentitiesController, type: :controller do
  describe 'PATCH disable_otp' do
    let(:identity) do
      create(:identity, otp_enabled: true)
    end
    let(:request) do
      patch :disable_otp, params: { id: identity.id }
    end

    describe 'when as identity owner' do
      before do
        sign_in identity.user
        request
        identity.reload
      end

      it 'updates identity' do
        expect(request.status).to eq 302
        expect(identity.otp_enabled).to be false
      end
    end

    describe 'when without permission' do
      before do
        sign_in create(:user)
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(request.status).to eq 403
        expect(identity.otp_enabled).to be true
      end
    end

    describe 'when as main-bartender' do
      before do
        sign_in create(:user, :main_bartender)
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(request.status).to eq 403
        expect(identity.otp_enabled).to be true
      end
    end

    describe 'when as treasurer' do
      before do
        sign_in create(:user, :treasurer)
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(request.status).to eq 403
        expect(identity.otp_enabled).to be true
      end
    end
  end
end
