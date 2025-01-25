require 'rails_helper'

describe SofiaAccountsController, type: :controller do
  describe 'GET new_activation_link' do
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
      get :new_activation_link, params: request_params
    end

    context 'when valid' do
      before do
        clear_enqueued_jobs
      end

      after do
        clear_enqueued_jobs
      end

      it 'shows success message and sends email' do
        request
        expect(assigns(:message)).to eq 'Er is een nieuwe activatielink voor uw account verstuurd naar uw emailadres.'
        expect(UserMailer).to send_email(:new_activation_link_email, :deliver_later, user)
        user.reload
        expect(user.activation_token).not_to be_nil
        expect(user.activation_token_valid_till).not_to be_nil
      end
    end

    context 'without email' do
      let(:old_user) { user.dup }

      before do
        user.update(email: nil)
        old_user
        clear_enqueued_jobs
        request
      end

      it 'shows error message and does not send email' do
        expect(user.dup.attributes).to eq old_user.attributes
        expect(assigns(:message)).to match(/uw account heeft geen emailadres/)
        expect(enqueued_jobs.size).to eq(0)
      end
    end

    context 'without user_id' do
      let(:old_user) { user.dup }

      before do
        request_params[:user_id] = nil
        old_user
        clear_enqueued_jobs
        request
      end

      it 'shows error message and does not send email' do
        expect(user.dup.attributes).to eq old_user.attributes
        expect(assigns(:message)).to match(/gebruikers-id is niet aanwezig/)
        expect(enqueued_jobs.size).to eq(0)
      end
    end

    context 'with user already activated' do
      let(:old_user) { user.dup }

      before do
        user.update(sofia_account: create(:sofia_account, user:))
        old_user
        clear_enqueued_jobs
        request
      end

      it 'shows error message and does not send email' do
        expect(user.dup.attributes).to eq old_user.attributes
        expect(assigns(:message)).to match(/uw account is al geactiveerd/)
        expect(enqueued_jobs.size).to eq(0)
      end
    end

    context 'with user_id of non-existent user' do
      let(:old_user) { user.dup }

      before do
        request_params[:user_id] = User.count + 1
        old_user
        clear_enqueued_jobs
        request
      end

      it 'shows error message and does not send email' do
        expect(user.dup.attributes).to eq old_user.attributes
        expect(assigns(:message)).to match(/uw account bestaat niet/)
        expect(enqueued_jobs.size).to eq(0)
      end
    end

    context 'with user_id of deactivated user' do
      let(:old_user) { user.dup }

      before do
        user.update(deactivated: true)
        old_user
        clear_enqueued_jobs
        request
      end

      it 'shows error message and does not send email' do
        expect(user.dup.attributes).to eq old_user.attributes
        expect(assigns(:message)).to match(/uw account is gedeactiveerd/)
        expect(enqueued_jobs.size).to eq(0)
      end
    end
  end
end
