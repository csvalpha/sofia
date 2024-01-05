require 'rails_helper'

RSpec.describe Role, type: :model do
  subject(:role) { build_stubbed(:role) }

  describe '#valid' do
    it { expect(role).to be_valid }

    context 'when without role_type' do
      subject(:role) { build_stubbed(:role, role_type: nil) }

      it { expect(role).not_to be_valid }
    end

    context 'when without group_uid' do
      subject(:role) { build_stubbed(:role, group_uid: nil) }

      it { expect(role).not_to be_valid }
    end
  end

  describe '#name' do
    context 'when treasurer' do
      subject(:role) { build_stubbed(:role, role_type: :treasurer) }

      it { expect(role.name).to eq Rails.application.config.x.treasurer_title.capitalize }
    end

    context 'when main bartender' do
      subject(:role) { build_stubbed(:role, role_type: :main_bartender) }

      it { expect(role.name).to eq 'Hoofdtapper' }
    end
  end
end
