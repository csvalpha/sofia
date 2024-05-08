require 'rails_helper'

describe "Identity login", type: :request do
  describe 'POST /users/auth/identity/callback' do
    let(:identity) do
      create(:identity, password: "password1234", password_confirmation: "password1234")
    end
    let(:user) { identity.user }
    # we need attrs, because omni-auth identity immediately transforms password into password_digest when building
    let(:request_params) { { 
      auth_key: identity.username, 
      password: identity.password, 
      verification_code: identity.otp_code
    } }
    let(:request) do
      post '/users/auth/identity/callback', params: request_params
    end

    context 'valid without otp' do
      before do 
        request
      end

      it 'creates a new identity and updates user' do
        # test response json
        expect(signed_in?(user)).to be true
      end
    end

    # context 'valid for user without email' do
    #   before do 
    #     user.update(email: nil)
    #     request_params[:user] = { email: Faker::Internet.email }
    #     request 
    #     user.reload
    #   end

    #   it 'creates a new identity and updates user' do
    #     expect(Identity.count).to eq 1
    #     expect(user.activation_token).to be_nil
    #     expect(user.activation_token_valid_till).to be_nil
    #     expect(user.email).to eq request_params[:user][:email]
    #   end

    #   it 'redirects after create' do
    #     request
    #     expect(response).to be_redirect
    #   end
    # end

    # context 'with email for user with email' do
    #   before do 
    #     @old_user = user.dup
    #     request_params[:user] = { email: Faker::Internet.email }
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/u heeft al een e-mailadres/)
    #   end
    # end

    # context 'without email for user without email' do
    #   before do 
    #     user.update(email: nil)
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/e-mailadres moet opgegeven zijn/)
    #   end
    # end

    # context 'with invalid email for user without email' do
    #   before do 
    #     user.update(email: nil)
    #     request_params[:user] = { email: "invalid_email" }
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/e-mailadres is ongeldig/)
    #   end
    # end

    # context 'without activation_token' do
    #   before do 
    #     request_params[:activation_token] = nil
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/activatie-token is niet aanwezig/)
    #   end
    # end

    # context 'without user_id' do
    #   before do 
    #     request_params[:user_id] = nil
    #     @old_user = user.dup
    #     request
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/gebruikers-id is niet aanwezig/)
    #   end
    # end

    # context 'with expired activation_token' do
    #   before do 
    #     user.update(activation_token_valid_till: Time.now - 1.minute)
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/de activatielink is verlopen of ongeldig/)
    #   end
    # end

    # context 'with wrong activation_token' do
    #   before do 
    #     request_params[:activation_token] = "other_token"
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/de activatielink is verlopen of ongeldig/)
    #   end
    # end

    # context 'with user already activated' do
    #   before do 
    #     user.update(identity: create(:identity, user: user))
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 1 # this 1 is for the one that already existed
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/uw account is al geactiveerd/)
    #   end
    # end

    # context 'without username' do
    #   before do 
    #     request_params[:identity][:username] = nil
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/gebruikersnaam moet opgegeven zijn/)
    #   end
    # end

    # context 'without password' do
    #   before do 
    #     request_params[:identity][:password] = nil
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/wachtwoord moet opgegeven zijn/)
    #   end
    # end

    # context 'without password_confirmation' do
    #   before do 
    #     request_params[:identity][:password_confirmation] = nil
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
    #   end
    # end

    # context 'with wrong password_confirmation' do
    #   before do 
    #     request_params[:identity][:password_confirmation] = "something_else"
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
    #   end
    # end

    # context 'with invalid password' do
    #   before do 
    #     request_params[:identity][:password] = "too_short"
    #     request_params[:identity][:password_confirmation] = "too_short"
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/wachtwoord is te kort/)
    #   end
    # end

    # context 'with user_id of non-existent user' do
    #   before do 
    #     request_params[:user_id] = User.count
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/uw account bestaat niet/)
    #   end
    # end

    # context 'with user_id of deactivated user' do
    #   before do 
    #     user.update(deactivated: true)
    #     @old_user = user.dup
    #     request 
    #     user.reload
    #   end

    #   it 'creates no new identity and does not update user' do
    #     expect(Identity.count).to eq 0
    #     expect(user.dup.attributes).to eq @old_user.attributes
    #     expect(flash[:error]).to match(/uw account is gedeactiveerd/)
    #   end
    # end
  end
end
