require 'rails_helper'

describe SofiaAccountsController do
  describe 'PATCH update_password' do
    let(:sofia_account) do
      create(:sofia_account, password: 'password1234', password_confirmation: 'password1234')
    end
    let(:user) { sofia_account.user }
    let(:request_params) do
      {
        id: sofia_account.id,
        sofia_account: {
          old_password: sofia_account.password,
          password: 'new_password1234',
          password_confirmation: 'new_password1234'
        }
      }
    end
    let(:request) do
      patch :update_password, params: request_params
    end

    describe 'when as sofia_account owner' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        sign_in user
        request
        sofia_account.reload
      end

      it 'updates sofia_account' do
        expect(request.status).to eq 302
        expect(sofia_account.authenticate(old_sofia_account.password)).to be false
        expect(sofia_account.authenticate(request_params[:sofia_account][:password])).to be sofia_account
      end
    end

    describe 'when as other user' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        sign_in create(:user)
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(request.status).to eq 403
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
      end
    end

    describe 'when as main-bartender' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        sign_in create(:user, :main_bartender)
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(request.status).to eq 403
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
      end
    end

    describe 'when as treasurer' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        sign_in create(:user, :treasurer)
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(request.status).to eq 403
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
      end
    end

    describe 'without old_password' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        request_params[:sofia_account][:old_password] = nil
        sign_in user
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/het oude wachtwoord is fout of niet opgegeven/)
      end
    end

    describe 'with wrong old_password' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        request_params[:sofia_account][:old_password] = 'something_else'
        sign_in user
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/het oude wachtwoord is fout of niet opgegeven/)
      end
    end

    describe 'without password' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        request_params[:sofia_account][:password] = nil
        sign_in user
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/wachtwoord moet opgegeven zijn/)
      end
    end

    describe 'with invalid password' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        request_params[:sofia_account][:password] = 'too_short'
        request_params[:sofia_account][:password_confirmation] = 'too_short'
        sign_in user
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/wachtwoord is te kort/)
      end
    end

    describe 'with non-matching confirmation' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        request_params[:sofia_account][:password_confirmation] = 'something_else'
        sign_in user
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
      end
    end

    describe 'without password_confirmation' do
      let(:old_sofia_account) { sofia_account.dup }

      before do
        old_sofia_account
        request_params[:sofia_account][:password_confirmation] = nil
        sign_in user
        request
        sofia_account.reload
      end

      it 'does not update sofia_account' do
        expect(sofia_account.dup.attributes).to eq old_sofia_account.attributes
        expect(flash[:error]).to match(/wachtwoord bevestiging komt niet overeen met wachtwoord/)
      end
    end
  end
end
