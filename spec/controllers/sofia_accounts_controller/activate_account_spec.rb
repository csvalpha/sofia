require 'rails_helper'

describe SofiaAccountsController, type: :controller do
  describe 'GET activate_account' do
    let(:user) do
      create(:user, :sofia_account, activation_token: SecureRandom.urlsafe_base64, activation_token_valid_till: 5.days.from_now)
    end
    let(:request_params) do
      {
        activation_token: user.activation_token,
        user_id: user.id
      }
    end
    let(:request) do
      get :activate_account, params: request_params
    end

    context 'without request_email for user with email' do
      before do
        request
      end

      it 'request_email to be false' do
        expect(assigns(:request_email)).to be false
      end

      it { expect(request.status).to eq 200 }
    end

    context 'without email' do
      before do
        user.update(email: nil)
        request
      end

      it 'request_email to be true' do
        expect(assigns(:request_email)).to be true
      end

      it { expect(request.status).to eq 200 }
    end

    context 'without user_id' do
      before do
        request_params = {
          activation_token: user.activation_token
        }
        request
      end

      it { expect(request.status).to eq 200 }
    end

    context 'without activation_token' do
      before do
        request_params = {
          user_id: user.id
        }
        request
      end

      it { expect(request.status).to eq 200 }
    end
  end
end
