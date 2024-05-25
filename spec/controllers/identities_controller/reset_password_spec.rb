require 'rails_helper'

describe IdentitiesController, type: :controller do
  describe 'PATCH reset_password' do
    let(:user) { create(:user, :identity, activation_token: SecureRandom.urlsafe_base64, activation_token_valid_till: Time.now + 5.day) }
    let(:identity) do
      create(:identity, user: user, password: "password1234", password_confirmation: "password1234")
    end
    let(:request_params) { { 
      id: identity.id,
      identity: { 
        password: "new_password1234", 
        password_confirmation: "new_password1234" 
      }, 
      activation_token: user.activation_token
    } }
    let(:request) do
      patch :reset_password, params: request_params
    end

    context 'valid' do
      before do 
        @old_identity = identity.dup
        request 
        identity.reload
      end

      it 'updates identity' do
        expect(identity.authenticate(@old_identity.password)).to be false 
        expect(identity.authenticate(request_params[:identity][:password])).to be identity
      end
    end

    context 'without activation_token' do
      before do 
        request_params[:activation_token] = nil
        @old_identity = identity.dup
        request 
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/activatie-token is niet aanwezig/)
      end
    end

    context 'with expired activation_token' do
      before do 
        user.update(activation_token_valid_till: Time.now - 1.minute)
        @old_identity = identity.dup
        request 
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/de resetlink is verlopen of ongeldig/)
      end
    end

    context 'with wrong activation_token' do
      before do 
        request_params[:activation_token] = "other_token"
        @old_identity = identity.dup
        request 
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/de resetlink is verlopen of ongeldig/)
      end
    end

    context 'without password' do
      before do 
        request_params[:identity][:password] = nil
        @old_identity = identity.dup
        request 
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/wachtwoord moet opgegeven zijn/)
      end
    end

    context 'without password_confirmation' do
      before do 
        request_params[:identity][:password_confirmation] = nil
        @old_identity = identity.dup
        request 
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
      end
    end

    context 'with wrong password_confirmation' do
      before do 
        request_params[:identity][:password_confirmation] = "something_else"
        @old_identity = identity.dup
        request 
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
      end
    end

    context 'with invalid password' do
      before do 
        request_params[:identity][:password] = "too_short"
        request_params[:identity][:password_confirmation] = "too_short"
        @old_identity = identity.dup
        request 
        identity.reload
      end

      it 'does not update identity' do
        expect(identity.dup.attributes).to eq @old_identity.attributes
        expect(flash[:error]).to match(/wachtwoord is te kort/)
      end
    end
  end
end
