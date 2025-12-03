require 'rails_helper'

describe SofiaAccountsController do
  describe 'PATCH reset_password' do
    let(:user) do
      create(:user, :sofia_account, activation_token: SecureRandom.urlsafe_base64, activation_token_valid_till: 5.days.from_now)
    end
    let(:sofia_account) do
      create(:sofia_account, user:, password: 'password1234', password_confirmation: 'password1234')
    end
    let(:request_params) do
      {
        id: sofia_account.id,
        sofia_account: {
          password: 'new_password1234',
          password_confirmation: 'new_password1234'
        },
        activation_token: user.activation_token
      }
    end
    let(:request) do
      patch :reset_password, params: request_params
    end

    context 'when valid' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        request
        sofia_account.reload
        user.reload
      end

      it 'updates sofia_account' do
        expect(sofia_account.authenticate(old_sofia_account.password)).to be false
        expect(sofia_account.authenticate(request_params[:sofia_account][:password])).to be sofia_account
        expect(user.activation_token).to be_nil
        expect(user.activation_token_valid_till).to be_nil
      end
    end

    context 'without activation_token' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        request_params[:activation_token] = nil
        old_sofia_account
        request
        sofia_account.reload
        user.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/activatie-token is niet aanwezig/)
        expect(user.activation_token).not_to be_nil
        expect(user.activation_token_valid_till).not_to be_nil
      end
    end

    context 'with expired activation_token' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        user.update(activation_token_valid_till: 1.minute.ago)
        old_sofia_account
        request
        sofia_account.reload
        user.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/de resetlink is verlopen of ongeldig/)
        expect(user.activation_token).not_to be_nil
        expect(user.activation_token_valid_till).not_to be_nil
      end
    end

    context 'with wrong activation_token' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        request_params[:activation_token] = SecureRandom.urlsafe_base64
        old_sofia_account
        request
        sofia_account.reload
        user.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/de resetlink is verlopen of ongeldig/)
        expect(user.activation_token).not_to be_nil
        expect(user.activation_token_valid_till).not_to be_nil
      end
    end

    context 'without password' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        request_params[:sofia_account][:password] = nil
        old_sofia_account
        request
        sofia_account.reload
        user.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/wachtwoord moet opgegeven zijn/)
        expect(user.activation_token).not_to be_nil
        expect(user.activation_token_valid_till).not_to be_nil
      end
    end

    context 'without password_confirmation' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        request_params[:sofia_account][:password_confirmation] = nil
        old_sofia_account
        request
        sofia_account.reload
        user.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
        expect(user.activation_token).not_to be_nil
        expect(user.activation_token_valid_till).not_to be_nil
      end
    end

    context 'with wrong password_confirmation' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        request_params[:sofia_account][:password_confirmation] = 'something_else'
        old_sofia_account
        request
        sofia_account.reload
        user.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
        expect(user.activation_token).not_to be_nil
        expect(user.activation_token_valid_till).not_to be_nil
      end
    end

    context 'with invalid password' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        request_params[:sofia_account][:password] = 'too_short'
        request_params[:sofia_account][:password_confirmation] = 'too_short'
        old_sofia_account
        request
        sofia_account.reload
        user.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/wachtwoord is te kort/)
        expect(user.activation_token).not_to be_nil
        expect(user.activation_token_valid_till).not_to be_nil
      end
    end
  end
end
