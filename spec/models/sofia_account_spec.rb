require 'rails_helper'

RSpec.describe SofiaAccount do
  subject(:sofia_account) do
    build_stubbed(:sofia_account, user: build_stubbed(:user, activation_token: SecureRandom.urlsafe_base64), password: 'password1234')
  end

  describe '#valid?' do
    it { expect(sofia_account).to be_valid }

    context 'with username' do
      context 'when without' do
        subject(:sofia_account) { build_stubbed(:sofia_account, username: nil) }

        it { expect(sofia_account).not_to be_valid }
      end

      context 'when containing spaces' do
        subject(:sofia_account) { build_stubbed(:sofia_account, username: 'contains two spaces') }

        it { expect(sofia_account).to be_valid }
      end

      context 'when empty string' do
        subject(:sofia_account) { build_stubbed(:sofia_account, username: '') }

        it { expect(sofia_account).not_to be_valid }
      end
    end

    context 'with password' do
      context 'when without' do
        subject(:sofia_account) do
          build_stubbed(:sofia_account, password: nil)
        end

        it { expect(sofia_account).not_to be_valid }
      end

      context 'when too short' do
        subject(:sofia_account) do
          build_stubbed(:sofia_account, password: '<12char')
        end

        it { expect(sofia_account).not_to be_valid }
      end

      context 'when empty string' do
        subject(:sofia_account) { build_stubbed(:sofia_account, password: '') }

        it { expect(sofia_account).not_to be_valid }
      end

      context 'when long enough' do
        subject(:sofia_account) { build_stubbed(:sofia_account, password: 'aaaaaaaaaaaa') }

        it { expect(sofia_account).to be_valid }
      end
    end

    context 'when having duplicate fields' do
      let(:sofia_account) { create(:sofia_account, password: 'password1234') }

      context 'with username' do
        subject(:duplicate_sofia_account) { build(:sofia_account, username: sofia_account.username) }

        it { expect(duplicate_sofia_account).not_to be_valid }
      end

      context 'with password' do
        subject(:duplicate_sofia_account) { build_stubbed(:sofia_account, password: sofia_account.password) }

        it { expect(duplicate_sofia_account).to be_valid }
      end

      context 'with user' do
        subject(:duplicate_sofia_account) { build_stubbed(:sofia_account, user: sofia_account.user) }

        it { expect(duplicate_sofia_account).not_to be_valid }
      end
    end
  end

  describe 'activate_account_url' do
    it { expect(described_class.activate_account_url(sofia_account.user.id, sofia_account.user.activation_token)).to eq "http://testhost:1337/sofia_accounts/activate_account?activation_token=#{sofia_account.user.activation_token}&user_id=#{sofia_account.user.id}" }
  end

  describe 'new_activation_link_url' do
    it { expect(described_class.new_activation_link_url(sofia_account.user.id)).to eq "http://testhost:1337/sofia_accounts/new_activation_link?user_id=#{sofia_account.user.id}" }
  end

  describe 'forgot_password_url' do
    it { expect(described_class.forgot_password_url).to eq 'http://testhost:1337/sofia_accounts/forgot_password' }
  end

  describe 'reset_password_url' do
    it { expect(sofia_account.reset_password_url(sofia_account.user.activation_token)).to eq "http://testhost:1337/sofia_accounts/#{sofia_account.id}/reset_password?activation_token=#{sofia_account.user.activation_token}" }
  end

  describe '.find_for_login' do
    let!(:account) { create(:sofia_account, username: 'testuser', password: 'password1234') }
    let!(:account_with_email) { create(:sofia_account, password: 'password1234') }

    context 'when searching by username' do
      it 'finds account by exact username match' do
        result = described_class.find_for_login('testuser')
        expect(result).to eq(account)
      end

      it 'does not find account by different case username' do
        result = described_class.find_for_login('TESTUSER')
        expect(result).to be_nil
      end

      it 'finds account by username with whitespace trimmed' do
        result = described_class.find_for_login('  testuser  ')
        expect(result).to eq(account)
      end
    end

    context 'when searching by email' do
      before do
        account_with_email.user.update!(email: 'user@example.com')
      end

      it 'finds account by exact email match' do
        result = described_class.find_for_login('user@example.com')
        expect(result).to eq(account_with_email)
      end

      it 'finds account by email regardless of case' do
        result = described_class.find_for_login('USER@EXAMPLE.COM')
        expect(result).to eq(account_with_email)
      end

      it 'finds account by email with whitespace trimmed' do
        result = described_class.find_for_login('  user@example.com  ')
        expect(result).to eq(account_with_email)
      end

      it 'prefers username match over email match' do
        account_with_email.update!(username: 'user@example.com')
        result = described_class.find_for_login('user@example.com')
        expect(result).to eq(account_with_email)
      end
    end

    context 'when handling nil or blank input' do
      it 'returns nil for nil or blank identifier' do
        expect(described_class.find_for_login(nil)).to be_nil
        expect(described_class.find_for_login('')).to be_nil
        expect(described_class.find_for_login('   ')).to be_nil
      end
    end

    context 'when no account matches' do
      it 'returns nil for non-existent username' do
        result = described_class.find_for_login('nonexistent')
        expect(result).to be_nil
      end

      it 'returns nil for non-existent email' do
        result = described_class.find_for_login('nonexistent@example.com')
        expect(result).to be_nil
      end
    end

    context 'when identifier resolves to an account' do
      let(:email_resolve_account) { create(:sofia_account, username: 'emailuser', password: 'password1234') }

      before do
        create(:sofia_account, username: 'resolveuser', password: 'password1234')
        email_resolve_account.user.update!(email: 'resolve@example.com')
      end

      it 'returns username when searched by username' do
        result = described_class.resolve_login_identifier('resolveuser')
        expect(result).to eq('resolveuser')
      end

      it 'returns username when searched by email' do
        result = described_class.resolve_login_identifier('resolve@example.com')
        expect(result).to eq(email_resolve_account.username)
      end

      it 'returns nil for mismatched username case' do
        result = described_class.resolve_login_identifier('RESOLVEUSER')
        expect(result).to be_nil
      end

      it 'normalizes case for email lookup' do
        result = described_class.resolve_login_identifier('RESOLVE@EXAMPLE.COM')
        expect(result).to eq(email_resolve_account.username)
      end

      it 'trims whitespace for username lookup' do
        result = described_class.resolve_login_identifier('  resolveuser  ')
        expect(result).to eq('resolveuser')
      end

      it 'trims whitespace for email lookup' do
        result = described_class.resolve_login_identifier('  resolve@example.com  ')
        expect(result).to eq(email_resolve_account.username)
      end
    end

    context 'when identifier does not resolve to an account' do
      it 'returns nil for nil, empty or non-existent identifiers' do
        expect(described_class.resolve_login_identifier(nil)).to be_nil
        expect(described_class.resolve_login_identifier('')).to be_nil
        expect(described_class.resolve_login_identifier('   ')).to be_nil
        expect(described_class.resolve_login_identifier('nonexistentuser')).to be_nil
        expect(described_class.resolve_login_identifier('nonexistent@example.com')).to be_nil
      end
    end
  end
end
