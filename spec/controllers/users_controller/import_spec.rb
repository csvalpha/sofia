require 'rails_helper'

describe UsersController do
  describe 'POST import' do
    let(:csv) { "naam,email\nJan Jansen,jan@example.com\nPiet Pietersen,piet@example.com\n" }
    let(:file) do
      tempfile = Tempfile.new(['users', '.csv'])
      tempfile.write(csv)
      tempfile.rewind
      Rack::Test::UploadedFile.new(tempfile.path, 'text/csv')
    end
    let(:request) { post :import, params: { file: } }

    before { allow(Rails.application.config.x).to receive(:subprovider_label).and_return(nil) }

    context 'when as treasurer' do
      before { sign_in create(:user, :treasurer) }

      it 'imports the users' do
        expect { request }.to change(User.sofia_account, :count).by(2)
        expect(response).to redirect_to users_path
        expect(flash[:success]).to include '2 gebruiker(s)'
      end

      it 'sends activation mails' do
        expect { request }.to have_enqueued_mail(UserMailer, :account_creation_email).twice
      end

      context 'with an invalid file' do
        let(:csv) { "naam,email\nJan Jansen,not-an-email\n" }

        it 'imports nobody and shows the errors' do
          expect { request }.not_to change(User, :count)
          expect(response).to redirect_to users_path
          expect(flash[:error]).to include 'Rij 2'
        end
      end

      context 'with many invalid rows' do
        let(:csv) { "naam,email\n#{(1..15).map { |i| "Gebruiker #{i}," }.join("\n")}\n" }

        it 'only shows the first errors' do
          request
          expect(flash[:error]).to include 'Rij 11', 'en nog 5 andere fout(en)'
          expect(flash[:error]).not_to include 'Rij 12'
        end
      end

      context 'without a file' do
        let(:request) { post :import }

        it 'shows an error' do
          request
          expect(response).to redirect_to users_path
          expect(flash[:error]).to eq 'Geen bestand geselecteerd'
        end
      end
    end

    %i[renting_manager main_bartender].each do |role|
      context "when as #{role}" do
        before { sign_in create(:user, role) }

        it 'is forbidden' do
          expect { request }.not_to change(User, :count)
          expect(response).to have_http_status :forbidden
        end
      end
    end

    context 'when as user without roles' do
      before { sign_in create(:user) }

      it 'is forbidden' do
        expect { request }.not_to change(User, :count)
        expect(response).to have_http_status :forbidden
      end
    end
  end
end
