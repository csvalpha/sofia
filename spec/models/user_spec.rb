require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryBot.build_stubbed(:user) }

  describe '#valid' do
    it { expect(user).to be_valid }

    context 'when without a name' do
      subject(:user) { FactoryBot.build_stubbed(:user, name: nil) }

      it { expect(user).not_to be_valid }
    end
  end

  describe '.in_banana' do
    context 'when in banana' do
      subject(:user) { FactoryBot.create(:user, provider: 'banana_oauth2') }

      before { user }

      it { expect(User.in_banana).to include user }
    end

    context 'when not in banana' do
      subject(:user) { FactoryBot.create(:user, provider: 'another_provider') }

      before { user }

      it { expect(User.in_banana).not_to include user }
    end
  end

  describe '#credit' do
    subject(:user) { FactoryBot.create(:user) }

    let(:order) { FactoryBot.create(:order, user: user) }
    let(:product_price) { FactoryBot.create(:product_price, price_list: order.activity.price_list, price: 1.23) }

    before do
      FactoryBot.create(:order_row, order: order, product: product_price.product, product_count: 1)
    end

    it { expect(user.credit).to eq(-1.23) }
  end

  describe '#roles' do
    context 'when with a role' do
      subject(:user) { FactoryBot.create(:user) }

      let(:role) { FactoryBot.create(:role) }

      before do
        FactoryBot.create(:roles_users, role: role, user: user)
      end

      it { expect(user.roles).to match_array [role] }
    end

    context 'when with a destroyed role' do
      subject(:user) { FactoryBot.create(:user) }

      let(:role) { FactoryBot.create(:role) }
      let(:roles_users) { FactoryBot.create(:roles_users, role: role, user: user) }

      before do
        roles_users
        roles_users.destroy
      end

      it { expect(user.roles).not_to match_array [role] }
    end


  end

  describe '#avatar_thumb_or_default_url' do
    context 'when with avatar thumb url' do
      subject(:user) { FactoryBot.create(:user, avatar_thumb_url: '/test.png') }

      it { expect(user.avatar_thumb_or_default_url).to eq "#{Rails.application.config.x.banana_api_host}/test.png" }
    end

    context 'when without avatar thumb url' do
      subject(:user) { FactoryBot.create(:user) }

      it { expect(user.avatar_thumb_or_default_url).to eq '/images/avatar_thumb_default.png' }
    end
  end

  describe '#treasurer?' do
    context 'when with treasurer role' do
      subject(:user) { FactoryBot.create(:user) }

      let(:role) { FactoryBot.create(:role, role_type: :treasurer) }

      before do
        FactoryBot.create(:roles_users, role: role, user: user)
      end

      it { expect(user.treasurer?).to eq true }
    end

    context 'when without treasurer role' do
      subject(:user) { FactoryBot.create(:user) }

      it { expect(user.treasurer?).to eq false }
    end
  end

  describe '#main_bartender?' do
    context 'when with main_bartender role' do
      subject(:user) { FactoryBot.create(:user) }

      let(:role) { FactoryBot.create(:role, role_type: :main_bartender) }

      before do
        FactoryBot.create(:roles_users, role: role, user: user)
      end

      it { expect(user.main_bartender?).to eq true }
    end

    context 'when without main_bartender role' do
      subject(:user) { FactoryBot.create(:user) }

      it { expect(user.main_bartender?).to eq false }
    end
  end

  describe '#update_role' do
    context 'when getting new roles' do
      subject(:user) { FactoryBot.create(:user) }
      let(:role) { FactoryBot.create(:role)}

      before do
        user.update_role([role.group_uid])
      end

      it { expect(user.roles).to include role}
    end

    context 'when losing roles' do
      subject(:user) { FactoryBot.create(:user) }
      let(:role) { FactoryBot.create(:role)}

      before do
        user.update_role([role.group_uid])
        user.update_role([])
      end

      it { expect(user.roles).not_to include role}
    end
  end

  describe 'full_name_from_attributes' do
    context 'when with all attributes' do
      it { expect(User.full_name_from_attributes('first', 'middle', 'last')). to eq 'first middle last'}
    end

    context 'when without middle name' do
      it { expect(User.full_name_from_attributes('first', '', 'last')). to eq 'first last'}
    end
  end
end
