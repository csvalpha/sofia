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

      it { expect(User.in_banana).to include user}
    end

    context 'when not in banana' do
      subject(:user) { FactoryBot.create(:user, provider: 'another_provider') }

      before { user }

      it { expect(User.in_banana).not_to include user}
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
    subject(:user) { FactoryBot.create(:user) }
    let(:role) { FactoryBot.create(:role)}

    before do
      FactoryBot.create(:roles_users, role: role, user: user)
    end

    it { expect(user.roles).to match_array [role]}
  end
end
