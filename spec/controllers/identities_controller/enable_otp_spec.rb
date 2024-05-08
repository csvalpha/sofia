require 'rails_helper'

describe IdentitiesController, type: :controller do
  describe 'PATCH enable_otp' do
    let(:identity) do
      create(:identity)
    end
    let(:user) { identity.user }
    let(:request_params) { { 
      id: identity.id,
      verification_code: identity.otp_code
    } }
    let(:request) do
      patch :enable_otp, params: request_params
    end

    describe 'when as identity owner' do
      before do
        sign_in user
        request
        identity.reload
      end

      it 'updates identity' do
        expect(request.status).to eq 302
        expect(identity.otp_enabled).to be true
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
        expect(identity.otp_enabled).to be false
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
        expect(identity.otp_enabled).to be false
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
        expect(identity.otp_enabled).to be false
      end
    end

    describe 'without verification_code' do
      before do
        request_params[:verification_code] = nil
        sign_in user
        begin request rescue ActionController::ParameterMissing end
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.otp_enabled).to be false
        expect { request  }.to raise_error(ActionController::ParameterMissing, /verification_code/)
      end
    end

    describe 'with wrong verication_code' do
      before do
        @old_identity = identity.dup
        request_params[:verification_code] = (request_params[:verification_code].to_i + 1).to_s
        sign_in user
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(request.status).to eq 302
        expect(identity.otp_enabled).to be false
        expect(flash[:error]).to match(/de verificatie token is ongeldig/)
      end
    end
  end
end
