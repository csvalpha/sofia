require 'rails_helper'

RSpec.describe RolesUsers do
  subject(:roles_users) { build_stubbed(:roles_users) }

  describe '#valid' do
    it { expect(roles_users).to be_valid }

    context 'when without user' do
      subject(:roles_users) { build_stubbed(:roles_users, user: nil) }

      it { expect(roles_users).not_to be_valid }
    end

    context 'when without role' do
      subject(:roles_users) { build_stubbed(:roles_users, role: nil) }

      it { expect(roles_users).not_to be_valid }
    end
  end
end
