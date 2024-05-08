require 'rails_helper'

describe IdentitiesController, type: :controller do
  describe 'GET activate_account' do
    let(:user) { create(:user, :identity, activation_token: SecureRandom.urlsafe_base64, activation_token_valid_till: Time.now + 5.day) }
    let(:request_params) { { 
      activation_token: user.activation_token, 
      user_id: user.id 
    } }
    let(:request) do
      get :activate_account, params: request_params
    end

    context 'no request_email for user with email' do
      before do 
        request 
      end

      it 'request_email to be false' do 
        expect(assigns(:request_email)).to be false
      end
    end

    context 'valid for user without email' do
      before do 
        user.update(email: nil)
        request 
      end

      it 'request_email to be true' do 
        expect(assigns(:request_email)).to be true
      end
    end
  end
end
