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
end
