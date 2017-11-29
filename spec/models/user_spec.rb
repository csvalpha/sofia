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

  describe '#credit' do
    subject(:user) { FactoryBot.create(:user) }

    let(:order) { FactoryBot.create(:order, user: user) }
    let(:product_price) { FactoryBot.create(:product_price, price_list: order.activity.price_list, price: 1.23) }

    before do
      FactoryBot.create(:order_row, order: order, product: product_price.product, product_count: 1)
    end

    it { expect(user.credit).to eq(-1.23) }
  end
end
