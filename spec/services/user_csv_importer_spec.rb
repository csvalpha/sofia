require 'rails_helper'

describe UserCsvImporter do
  subject(:importer) { described_class.new(content) }

  let(:subprovider_label) { nil }
  let(:content) do
    <<~CSV
      naam,email,geboortedatum
      Jan Jansen,jan@example.com,17-05-2001
      Piet Pietersen,piet@example.com,
    CSV
  end

  before { allow(Rails.application.config.x).to receive(:subprovider_label).and_return(subprovider_label) }

  describe '#import' do
    context 'with a valid file' do
      it 'creates sofia account users' do
        expect { importer.import }.to change(User.sofia_account, :count).by(2)
        expect(importer.errors).to be_empty
      end

      it 'stores the attributes' do
        importer.import
        user = User.find_by(email: 'jan@example.com')
        expect(user.name).to eq 'Jan Jansen'
        expect(user.birthday).to eq Date.new(2001, 5, 17)
        expect(User.find_by(email: 'piet@example.com').birthday).to be_nil
      end

      it 'sends an activation mail to every user' do
        expect { importer.import }.to have_enqueued_mail(UserMailer, :account_creation_email).twice
      end

      it { expect(importer.import).to be true }
    end

    context 'with the example file that can be downloaded' do
      let(:content) { Rails.public_path.join('voorbeeld_gebruikers_import.csv').read }

      it 'imports all users' do
        expect { importer.import }.to change(User, :count).by(3)
        expect(importer.errors).to be_empty
      end
    end

    context 'with semicolons, a byte order mark, english headers and blank lines' do
      let(:content) { "﻿Name;E-mail;Birthday\r\nJan Jansen;jan@example.com;1-5-2001\r\n;;\r\n" }

      it 'creates the user' do
        expect { importer.import }.to change(User, :count).by(1)
        expect(User.last.birthday).to eq Date.new(2001, 5, 1)
      end
    end

    context 'with a Windows-1252 encoded file' do
      let(:content) { "naam;email\nRené Smit;rene@example.com\n".encode('Windows-1252').force_encoding('ASCII-8BIT') }

      it 'converts the name to UTF-8' do
        importer.import
        expect(User.last.name).to eq 'René Smit'
      end
    end

    context 'with one invalid row' do
      let(:content) do
        <<~CSV
          naam,email,geboortedatum
          Jan Jansen,jan@example.com,17-05-2001
          ,not-an-email,
        CSV
      end

      it 'imports nobody' do
        expect { importer.import }.not_to change(User, :count)
      end

      it 'reports the row' do
        importer.import
        expect(importer.errors.join).to include 'Rij 3'
      end

      it { expect(importer.import).to be false }
    end

    context 'with a missing email' do
      let(:content) { "naam,email\nJan Jansen,\n" }

      it 'reports the row' do
        expect(importer.import).to be false
        expect(importer.errors).to eq ['Rij 2: E-mailadres moet ingevuld zijn']
      end
    end

    context 'with a birthday in the wrong format' do
      let(:content) { "naam,email,geboortedatum\nJan Jansen,jan@example.com,2001-05-17\n" }

      it 'reports the row' do
        expect(importer.import).to be false
        expect(importer.errors.first).to include 'Rij 2', 'DD-MM-JJJJ'
      end
    end

    context 'with a birthday that does not exist' do
      let(:content) { "naam,email,geboortedatum\nJan Jansen,jan@example.com,31-02-2001\n" }

      it 'reports the row' do
        expect(importer.import).to be false
        expect(importer.errors.first).to include 'bestaat niet'
      end
    end

    context 'with a birthday in the future' do
      let(:content) { "naam,email,geboortedatum\nJan Jansen,jan@example.com,#{1.day.from_now.strftime('%d-%m-%Y')}\n" }

      it { expect(importer.import).to be false }
    end

    context 'with an email that is already in use' do
      before { create(:user, :sofia_account, email: 'jan@example.com') }

      it 'imports nobody' do
        expect { importer.import }.not_to change(User, :count)
        expect(importer.errors.first).to include 'Rij 2'
      end
    end

    context 'with the same email twice in the file' do
      let(:content) { "naam,email\nJan Jansen,jan@example.com\nJan Jansen,JAN@example.com\n" }

      it 'reports the second row' do
        expect(importer.import).to be false
        expect(importer.errors).to eq ['Rij 3: E-mailadres staat meerdere keren in het bestand']
      end
    end

    context 'with a missing column' do
      let(:content) { "naam\nJan Jansen\n" }

      it 'reports the column' do
        expect(importer.import).to be false
        expect(importer.errors).to eq ['Ontbrekende kolom(men): email']
      end
    end

    context 'with only a header' do
      let(:content) { "naam,email\n" }

      it 'reports that there are no users' do
        expect(importer.import).to be false
        expect(importer.errors).to eq ['Het bestand bevat geen gebruikers']
      end
    end

    context 'with a malformed file' do
      let(:content) { "naam,email\n\"Jan,jan@example.com\n" }

      it 'reports that the file cannot be read' do
        expect(importer.import).to be false
        expect(importer.errors.first).to include 'kon niet gelezen worden'
      end
    end

    context 'when a subprovider is required' do
      let(:subprovider_label) { 'Vereniging' }

      context 'without a subprovider column' do
        it 'reports the column' do
          expect(importer.import).to be false
          expect(importer.errors).to eq ['Ontbrekende kolom(men): subprovider']
        end
      end

      context 'with a subprovider column' do
        let(:content) { "naam,email,subprovider\nJan Jansen,jan@example.com,abc\nPiet,piet@example.com,\n" }

        it 'requires a value on every row' do
          expect(importer.import).to be false
          expect(importer.errors).to eq ['Rij 3: Subprovider moet ingevuld zijn']
        end
      end

      context 'with a subprovider on every row' do
        let(:content) { "naam,email,subprovider\nJan Jansen,jan@example.com,abc\n" }

        it 'stores it in uppercase' do
          importer.import
          expect(User.last.sub_provider).to eq 'ABC'
        end
      end
    end
  end
end
