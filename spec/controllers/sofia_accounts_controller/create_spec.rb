require 'rails_helper'

describe SofiaAccountsController do
  describe 'POST create' do
    let(:user) do
      create(:user, :sofia_account, activation_token: SecureRandom.urlsafe_base64, activation_token_valid_till: 5.days.from_now)
    end
    # we need attrs, because omni-auth identity immediately transforms password into password_digest when building
    let(:request_params) do
      {
        sofia_account: {
          username: Faker::Internet.username,
          password: 'password1234',
          password_confirmation: 'password1234'
        },
        activation_token: user.activation_token,
        user_id: user.id
      }
    end
    let(:request) do
      post :create, params: request_params
    end

    context 'without email for user with email' do
      let(:old_email) { user.email }

      before do
        old_email
        request
        user.reload
      end

      it 'creates a new sofia_account and updates user' do
        expect(SofiaAccount.count).to eq 1
        expect(user.sofia_account).not_to be_nil
        expect(user.activation_token).to be_nil
        expect(user.activation_token_valid_till).to be_nil
        expect(user.email).to eq old_email
      end

      it 'redirects after create' do
        expect(response).to be_redirect
      end
    end

    context 'with email for user without email' do
      before do
        user.update(email: nil)
        request_params[:user] = { email: Faker::Internet.email }
        request
        user.reload
      end

      it 'creates a new sofia_account and updates user' do
        expect(SofiaAccount.count).to eq 1
        expect(user.sofia_account).not_to be_nil
        expect(user.activation_token).to be_nil
        expect(user.activation_token_valid_till).to be_nil
        expect(user.email).to eq request_params[:user][:email]
      end

      it 'redirects after create' do
        request
        expect(response).to be_redirect
      end
    end

    context 'with email for user with email' do
      let(:old_user) { user.dup }

      before do
        old_user
        request_params[:user] = { email: Faker::Internet.email }
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/u heeft al een e-mailadres/)
      end
    end

    context 'without email for user without email' do
      let(:old_user) { user.dup }

      before do
        user.update(email: nil)
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/e-mailadres moet opgegeven zijn/)
      end
    end

    context 'with invalid email for user without email' do
      let(:old_user) { user.dup }

      before do
        user.update(email: nil)
        request_params[:user] = { email: 'invalid_email' }
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/e-mailadres is ongeldig/)
      end
    end

    context 'without activation_token' do
      let(:old_user) { user.dup }

      before do
        request_params[:activation_token] = nil
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/Activatie-token is niet aanwezig/)
      end
    end

    context 'without user_id' do
      let(:old_user) { user.dup }

      before do
        request_params[:user_id] = nil
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/Gebruikers-id is niet aanwezig/)
      end
    end

    context 'with expired activation_token' do
      let(:old_user) { user.dup }

      before do
        user.update(activation_token_valid_till: 1.minute.ago)
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/de activatielink is verlopen of ongeldig/)
      end
    end

    context 'with wrong activation_token' do
      let(:old_user) { user.dup }

      before do
        request_params[:activation_token] = SecureRandom.urlsafe_base64
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/de activatielink is verlopen of ongeldig/)
      end
    end

    context 'with user already activated' do
      let(:old_user) { user.dup }

      before do
        create(:sofia_account, user:)
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 1 # this 1 is for the one that already existed
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/uw account is al geactiveerd/)
      end
    end

    context 'without username' do
      let(:old_user) { user.dup }

      before do
        request_params[:sofia_account][:username] = nil
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/gebruikersnaam moet opgegeven zijn/)
      end
    end

    context 'without password' do
      let(:old_user) { user.dup }

      before do
        request_params[:sofia_account][:password] = nil
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/wachtwoord moet opgegeven zijn/)
      end
    end

    context 'without password_confirmation' do
      let(:old_user) { user.dup }

      before do
        request_params[:sofia_account][:password_confirmation] = nil
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
      end
    end

    context 'with wrong password_confirmation' do
      let(:old_user) { user.dup }

      before do
        request_params[:sofia_account][:password_confirmation] = 'something_else'
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
      end
    end

    context 'with invalid password' do
      let(:old_user) { user.dup }

      before do
        request_params[:sofia_account][:password] = 'too_short'
        request_params[:sofia_account][:password_confirmation] = 'too_short'
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/wachtwoord is te kort/)
      end
    end

    context 'with user_id of non-existent user' do
      let(:old_user) { user.dup }

      before do
        request_params[:user_id] = User.count
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/uw account bestaat niet/)
      end
    end

    context 'with user_id of deactivated user' do
      let(:old_user) { user.dup }

      before do
        user.update(deactivated: true)
        old_user
        request
        user.reload
      end

      it 'creates no new sofia_account and does not update user' do
        expect(SofiaAccount.count).to eq 0
        expect(user.sofia_account).to be_nil
        expect(user.dup.attributes).to eq old_user.attributes
        expect(flash[:error]).to match(/uw account is gedeactiveerd/)
      end
    end
  end
end
