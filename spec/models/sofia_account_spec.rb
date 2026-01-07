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

      it 'finds account by username regardless of case' do
        result = described_class.find_for_login('TESTUSER')
        expect(result).to eq(account)
      end

      it 'finds account by username with mixed case' do
        result = described_class.find_for_login('TestUser')
        expect(result).to eq(account)
      end

      it 'finds account by username with surrounding whitespace' do
        result = described_class.find_for_login('  testuser  ')
        expect(result).to eq(account)
      end

      it 'finds account by username with leading whitespace' do
        result = described_class.find_for_login('  testuser')
        expect(result).to eq(account)
      end

      it 'finds account by username with trailing whitespace' do
        result = described_class.find_for_login('testuser  ')
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

      it 'finds account by email with mixed case' do
        result = described_class.find_for_login('User@Example.Com')
        expect(result).to eq(account_with_email)
      end

      it 'finds account by email with surrounding whitespace' do
        result = described_class.find_for_login('  user@example.com  ')
        expect(result).to eq(account_with_email)
      end

      it 'finds account by email with leading whitespace' do
        result = described_class.find_for_login('  user@example.com')
        expect(result).to eq(account_with_email)
      end

      it 'finds account by email with trailing whitespace' do
        result = described_class.find_for_login('user@example.com  ')
        expect(result).to eq(account_with_email)
      end

      it 'prefers username match over email match' do
        account_with_email.update!(username: 'user@example.com')
        result = described_class.find_for_login('user@example.com')
        expect(result).to eq(account_with_email)
      end
    end

    context 'when handling nil or blank input' do
      it 'returns nil for nil identifier' do
        result = described_class.find_for_login(nil)
        expect(result).to be_nil
      end

      it 'returns nil for empty string' do
        result = described_class.find_for_login('')
        expect(result).to be_nil
      end

      it 'returns nil for whitespace-only string' do
        result = described_class.find_for_login('   ')
        expect(result).to be_nil
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

      it 'returns nil when user exists but email is nil' do
        user_without_email = create(:user, email: nil)
        create(:sofia_account, user: user_without_email, password: 'password1234')
        result = described_class.find_for_login('anyvalue@example.com')
        expect(result).to be_nil
      end
    end

    context 'with multiple accounts and unique test data' do
      let!(:alpha_account) { create(:sofia_account, username: 'AlphaUser', password: 'password1234') }
      let!(:beta_account) { create(:sofia_account, username: 'BetaUser', password: 'password1234') }
      let!(:gamma_account) { create(:sofia_account, password: 'password1234') }

      before do
        gamma_account.user.update!(email: 'gamma_user@domain.io')
      end

      it 'finds correct account among multiple by username' do
        expect(described_class.find_for_login('AlphaUser')).to eq(alpha_account)
        expect(described_class.find_for_login('BetaUser')).to eq(beta_account)
      end

      it 'finds correct account among multiple by email' do
        expect(described_class.find_for_login('gamma_user@domain.io')).to eq(gamma_account)
      end

      it 'handles case-insensitive lookup for each account independently' do
        expect(described_class.find_for_login('alphauser')).to eq(alpha_account)
        expect(described_class.find_for_login('betauser')).to eq(beta_account)
        expect(described_class.find_for_login('GAMMA_USER@DOMAIN.IO')).to eq(gamma_account)
      end
    end
  end

  describe '.resolve_login_identifier' do
    let!(:email_account) { create(:sofia_account, password: 'password1234') }

    before do
      create(:sofia_account, username: 'resolveuser', password: 'password1234')
      email_account.user.update!(email: 'resolve@example.com')
    end

    context 'when identifier resolves to an account' do
      it 'returns username when searched by username' do
        result = described_class.resolve_login_identifier('resolveuser')
        expect(result).to eq('resolveuser')
      end

      it 'returns username when searched by email' do
        result = described_class.resolve_login_identifier('resolve@example.com')
        expect(result).to eq(email_account.username)
      end

      it 'normalizes case for username lookup' do
        result = described_class.resolve_login_identifier('RESOLVEUSER')
        expect(result).to eq('resolveuser')
      end

      it 'normalizes case for email lookup' do
        result = described_class.resolve_login_identifier('RESOLVE@EXAMPLE.COM')
        expect(result).to eq(email_account.username)
      end

      it 'trims whitespace for username lookup' do
        result = described_class.resolve_login_identifier('  resolveuser  ')
        expect(result).to eq('resolveuser')
      end

      it 'trims whitespace for email lookup' do
        result = described_class.resolve_login_identifier('  resolve@example.com  ')
        expect(result).to eq(email_account.username)
      end
    end

    context 'when identifier does not resolve to an account' do
      it 'returns nil for nil identifier' do
        result = described_class.resolve_login_identifier(nil)
        expect(result).to be_nil
      end

      it 'returns nil for empty string' do
        result = described_class.resolve_login_identifier('')
        expect(result).to be_nil
      end

      it 'returns nil for blank identifier' do
        result = described_class.resolve_login_identifier('   ')
        expect(result).to be_nil
      end

      it 'returns nil for non-existent username' do
        result = described_class.resolve_login_identifier('nonexistentuser')
        expect(result).to be_nil
      end

      it 'returns nil for non-existent email' do
        result = described_class.resolve_login_identifier('nonexistent@example.com')
        expect(result).to be_nil
      end
    end

    context 'with multiple accounts and varied normalization' do
      let!(:account_three) { create(:sofia_account, password: 'password1234') }

      before do
        create(:sofia_account, username: 'FirstResolver', password: 'password1234')
        create(:sofia_account, username: 'SecondResolver', password: 'password1234')
        account_three.user.update!(email: 'thirdresolver@domain.org')
      end

      it 'returns correct username for first account with case variation' do
        result = described_class.resolve_login_identifier('firstresolver')
        expect(result).to eq('FirstResolver')
      end

      it 'returns correct username for second account with case variation' do
        result = described_class.resolve_login_identifier('secondresolver')
        expect(result).to eq('SecondResolver')
      end

      it 'returns correct username for email account with case variation' do
        result = described_class.resolve_login_identifier('THIRDRESOLVER@DOMAIN.ORG')
        expect(result).to eq(account_three.username)
      end

      it 'applies whitespace trimming across all lookup types' do
        expect(described_class.resolve_login_identifier('  firstresolver  ')).to eq('FirstResolver')
        expect(described_class.resolve_login_identifier('  secondresolver  ')).to eq('SecondResolver')
        expect(described_class.resolve_login_identifier('  thirdresolver@domain.org  ')).to eq(account_three.username)
      end
    end
  end
end
