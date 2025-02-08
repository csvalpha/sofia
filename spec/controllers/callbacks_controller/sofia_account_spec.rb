require 'rails_helper'

# Disable omni-auth log messages in test report
OmniAuth.config.logger = Rails.logger

describe 'SofiaAccount login', type: :request do
  describe 'POST /users/auth/identity/callback' do
    let(:sofia_account) do
      create(:sofia_account, password: 'password1234', password_confirmation: 'password1234')
    end
    let(:user) { sofia_account.user }
    let(:request_params) do
      {
        auth_key: sofia_account.username,
        password: sofia_account.password,
        verification_code: sofia_account.otp_code
      }
    end
    let(:request) do
      post '/users/auth/identity/callback', params: request_params
    end

    context 'with non-existent sofia_account' do
      before do
        request_params[:auth_key] = 'something_else'
        request
      end

      it 'does not log in user' do
        expect(signed_in?(nil)).to be true
      end

      it 'sends a json response' do
        expect(response.content_type).to eq 'application/json; charset=utf-8'
        expect(response.parsed_body['state']).to eq 'password_prompt'
        expect(response.parsed_body['error_message']).to eq 'Inloggen mislukt. De ingevulde gegevens zijn incorrect.'
      end
    end

    context 'with sofia_account without otp' do
      context 'when valid login' do
        before do
          request
        end

        it 'logs in user' do
          expect(signed_in?(user)).to be true
        end

        it 'sends a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
          expect(response.parsed_body['state']).to eq 'logged_in'
          expect(response.parsed_body['error_message']).to be_nil
          expect(response.parsed_body['redirect_url']).to eq user_path(user.id)
        end
      end

      context 'when wrong password' do
        before do
          request_params[:password] = 'something_else'
          request
        end

        it 'does not log in user' do
          expect(signed_in?(user)).to be false
        end

        it 'sends a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
          expect(response.parsed_body['state']).to eq 'password_prompt'
          expect(response.parsed_body['error_message']).to eq 'Inloggen mislukt. De ingevulde gegevens zijn incorrect.'
        end
      end
    end

    context 'with sofia_account with otp' do
      context 'when valid login' do
        before do
          sofia_account.update(otp_enabled: true)
          request
        end

        it 'logs in user' do
          expect(signed_in?(user)).to be true
        end

        it 'sends a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
          expect(response.parsed_body['state']).to eq 'logged_in'
          expect(response.parsed_body['error_message']).to be_nil
          expect(response.parsed_body['redirect_url']).to eq user_path(user.id)
        end
      end

      context 'with wrong password' do
        before do
          sofia_account.update(otp_enabled: true)
          request_params[:password] = 'something_else'
          request
        end

        it 'does not log in user' do
          expect(signed_in?(user)).to be false
        end

        it 'sends a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
          expect(response.parsed_body['state']).to eq 'password_prompt'
          expect(response.parsed_body['error_message']).to eq 'Inloggen mislukt. De ingevulde gegevens zijn incorrect.'
        end
      end

      context 'without otp code' do
        before do
          sofia_account.update(otp_enabled: true)
          request_params[:verification_code] = nil
          request
        end

        it 'does not log in user' do
          expect(signed_in?(user)).to be false
        end

        it 'sends a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
          expect(response.parsed_body['state']).to eq 'otp_prompt'
          expect(response.parsed_body['error_message']).to be_nil
        end
      end

      context 'with wrong otp code' do
        before do
          sofia_account.update(otp_enabled: true)
          request_params[:verification_code] = 'something_else'
          request
        end

        it 'does not log in user' do
          expect(signed_in?(user)).to be false
        end

        it 'sends a json response' do
          expect(response.content_type).to eq 'application/json; charset=utf-8'
          expect(response.parsed_body['state']).to eq 'otp_prompt'
          expect(response.parsed_body['error_message']).to eq 'Inloggen mislukt. De authenticatiecode is incorrect.'
        end
      end
    end
  end
end
