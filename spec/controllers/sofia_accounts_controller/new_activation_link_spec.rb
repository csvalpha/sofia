require 'rails_helper'

describe SofiaAccountsController do
  describe 'GET new_activation_link' do
    let(:generic_message) { 'Er is een activatielink verzonden als het account bestaat.' }
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

      it 'shows generic message and sends email' do
        expect { request }.to have_enqueued_mail(UserMailer, :new_activation_link_email).with(user)
        expect(assigns(:message)).to eq generic_message
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
      end

      it 'shows generic message and does not send email' do
        expect { request }.not_to have_enqueued_mail(UserMailer, :new_activation_link_email)
        expect(assigns(:message)).to eq generic_message
        user.reload
        expect(user.dup.attributes).to eq old_user.attributes
      end
    end

    context 'without user_id' do
      let(:old_user) { user.dup }

      before do
        request_params[:user_id] = nil
        old_user
        clear_enqueued_jobs
      end

      it 'shows error message and does not send email' do
        expect { request }.not_to have_enqueued_mail(UserMailer, :new_activation_link_email)
        expect(assigns(:message)).to match(/gebruikers-id is niet aanwezig/)
        user.reload
        expect(user.dup.attributes).to eq old_user.attributes
      end
    end

    context 'with user already activated' do
      let(:old_user) { user.dup }

      before do
        user.update(sofia_account: create(:sofia_account, user:))
        old_user
        clear_enqueued_jobs
      end

      it 'shows generic message and does not send email' do
        expect { request }.not_to have_enqueued_mail(UserMailer, :new_activation_link_email)
        expect(assigns(:message)).to eq generic_message
        user.reload
        expect(user.dup.attributes).to eq old_user.attributes
      end
    end

    context 'with user_id of non-existent user' do
      let(:old_user) { user.dup }

      before do
        request_params[:user_id] = User.maximum(:id).to_i + 1
        old_user
        clear_enqueued_jobs
      end

      it 'shows generic message and does not send email' do
        expect { request }.not_to have_enqueued_mail(UserMailer, :new_activation_link_email)
        expect(assigns(:message)).to eq generic_message
        user.reload
        expect(user.dup.attributes).to eq old_user.attributes
      end
    end

    context 'with user_id of deactivated user' do
      let(:old_user) { user.dup }

      before do
        user.update(deactivated: true)
        old_user
        clear_enqueued_jobs
      end

      it 'shows generic message and does not send email' do
        expect { request }.not_to have_enqueued_mail(UserMailer, :new_activation_link_email)
        expect(assigns(:message)).to eq generic_message
        user.reload
        expect(user.dup.attributes).to eq old_user.attributes
      end
    end
  end
end
