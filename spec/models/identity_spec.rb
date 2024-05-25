require 'rails_helper'

RSpec.describe Identity, type: :model do
  subject(:identity) { build_stubbed(:identity, user: build_stubbed(:user, activation_token: SecureRandom.urlsafe_base64), password: 'password1234') }

  describe '#valid?' do
    it { expect(identity).to be_valid }

    context 'when without a username' do
      subject(:identity) { build_stubbed(:identity, username: nil) }

      it { expect(identity).not_to be_valid }
    end

    context 'when with a username containing spaces' do
      subject(:identity) { build_stubbed(:identity, username: 'contains a space') }

      it { expect(identity).to be_valid }
    end

    context 'when having duplicate fields' do
      let(:identity) { create(:identity) }

      context 'username' do
        subject(:duplicate_identity) { build_stubbed(:identity, username: identity.username) }

        it { expect(duplicate_identity).not_to be_valid }
      end

      context 'user' do
        subject(:duplicate_identity) { build_stubbed(:identity, user: identity.user) }

        it { expect(duplicate_identity).not_to be_valid }
      end
    end

    context 'when without a password' do
      subject(:identity) do
        build_stubbed(:identity, password: nil)
      end

      it { expect(identity).not_to be_valid }
    end

    context 'when with too short password' do
      subject(:identity) do
        build_stubbed(:identity, password: '<12char')
      end

      it { expect(identity).not_to be_valid }
    end

    context 'when with empty password' do
      subject(:identity) { build_stubbed(:identity, password: '') }

      it { expect(identity).not_to be_valid }
    end

    context 'when with password' do
      subject(:identity) { build_stubbed(:identity, password: 'password1234') }

      it { expect(identity).to be_valid }
    end
  end

  describe 'activate_account_url' do
    it { expect(Identity.activate_account_url(identity.user.id, identity.user.activation_token)).to eq "http://testhost:1337/identities/activate_account?activation_token=#{identity.user.activation_token}&user_id=#{identity.user.id}" }
  end

  describe 'new_activation_link_url' do
    it { expect(Identity.new_activation_link_url(identity.user.id)).to eq "http://testhost:1337/identities/new_activation_link?user_id=#{identity.user.id}" }
  end

  describe 'forgot_password_url' do
    it { expect(Identity.forgot_password_url()).to eq "http://testhost:1337/identities/forgot_password" }
  end

  describe 'reset_password_url' do
    it { expect(identity.reset_password_url(identity.user.activation_token)).to eq "http://testhost:1337/identities/#{identity.id}/reset_password?activation_token=#{identity.user.activation_token}" }
  end
end
