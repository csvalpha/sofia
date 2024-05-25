require 'rails_helper'

describe IdentitiesController, type: :controller do
  describe 'PATCH update_password' do
    let(:identity) do
      create(:identity, password: "password1234", password_confirmation: "password1234")
    end
    let(:user) { identity.user }
    let(:request_params) { { 
      id: identity.id,
      identity: { 
        old_password: identity.password,
        password: "new_password1234", 
        password_confirmation: "new_password1234"
      }
    } }
    let(:request) do
      patch :update_password, params: request_params
    end

    describe 'when as identity owner' do
      before do
        @old_identity = identity.dup
        sign_in user
        request
        identity.reload
      end

      it 'updates identity' do
        expect(request.status).to eq 302
        expect(identity.authenticate(@old_identity.password)).to be false 
        expect(identity.authenticate(request_params[:identity][:password])).to be identity
      end
    end

    describe 'when without permission' do
      before do
        @old_identity = identity.dup
        sign_in create(:user)
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(request.status).to eq 403
        expect(identity.dup.attributes).to eq @old_identity.attributes
      end
    end

    describe 'when as main-bartender' do
      before do
        @old_identity = identity.dup
        sign_in create(:user, :main_bartender)
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(request.status).to eq 403
        expect(identity.dup.attributes).to eq @old_identity.attributes
      end
    end

    describe 'when as treasurer' do
      before do
        @old_identity = identity.dup
        sign_in create(:user, :treasurer)
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(request.status).to eq 403
        expect(identity.dup.attributes).to eq @old_identity.attributes
      end
    end

    describe 'without old_password' do
      before do
        @old_identity = identity.dup
        request_params[:identity][:old_password] = nil
        sign_in user
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/het oude wachtwoord is fout of niet opgegeven/)
      end
    end

    describe 'with wrong old_password' do
      before do
        @old_identity = identity.dup
        request_params[:identity][:old_password] = "something_else"
        sign_in user
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/het oude wachtwoord is fout of niet opgegeven/)
      end
    end

    describe 'without password' do
      before do
        @old_identity = identity.dup
        request_params[:identity][:password] = nil
        sign_in user
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/wachtwoord moet opgegeven zijn/)
      end
    end

    describe 'with invalid password' do
      before do
        @old_identity = identity.dup
        request_params[:identity][:password] = "too_short"
        request_params[:identity][:password_confirmation] = "too_short"
        sign_in user
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/wachtwoord is te kort/)
      end
    end

    describe 'with non-matching confirmation' do
      before do
        @old_identity = identity.dup
        request_params[:identity][:password_confirmation] = "something_else"
        sign_in user
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
      end
    end


    describe 'without password_confirmation' do
      before do
        @old_identity = identity.dup
        request_params[:identity][:password_confirmation] = nil
        sign_in user
        request
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
      end
    end
  end
end
