require 'rails_helper'

describe SofiaAccountsController, type: :controller do
  describe 'POST forgot_password' do
    let(:user) { create(:user, :sofia_account) }
    let(:sofia_account) { create(:sofia_account, user: user) }
    # we need attrs, because omni-auth identity immediately transforms password into password_digest when building
    let(:request_params) do
      {
        username: sofia_account.username
      }
    end
    let(:request) do
      post :forgot_password, params: request_params
    end

    context 'valid' do
      before do
        clear_enqueued_jobs
      end

      after do
        clear_enqueued_jobs
      end

      it 'shows success message and sends email' do
        expect(UserMailer).to send_email(:forgot_password_email, :deliver_later, user)
        request
        user.reload
        expect(user.activation_token).not_to be_nil
        expect(user.activation_token_valid_till).not_to be_nil
      end
    end

    context 'user without email' do
      before do
        user.update(email: nil)
        @old_user = user.dup
        clear_enqueued_jobs
        request
        user.reload
      end

      it 'shows error message and does not send email' do
        expect(user.dup.attributes).to eq @old_user.attributes
        expect(flash[:error]).to match(/uw account heeft geen emailadres/)
        expect(enqueued_jobs.size).to eq(0)
      end
    end

    context 'without username' do
      before do
        request_params[:username] = nil
        @old_user = user.dup
        clear_enqueued_jobs
        request
        user.reload
      end

      it 'shows error message and does not send email' do
        expect(user.dup.attributes).to eq @old_user.attributes
        expect(flash[:error]).to match(/gebruikersnaam is niet aanwezig/)
        expect(enqueued_jobs.size).to eq(0)
      end
    end

    context 'with non-existent username' do
      before do
        request_params[:username] = 'something_else'
        @old_user = user.dup
        clear_enqueued_jobs
        request
        user.reload
      end

      it 'shows error message and does not send email' do
        expect(user.dup.attributes).to eq @old_user.attributes
        expect(flash[:error]).to match(/gebruikersnaam bestaat niet/)
        expect(enqueued_jobs.size).to eq(0)
      end
    end
  end
end
