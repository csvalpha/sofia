require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { FactoryGirl.build_stubbed(:user) }

  describe '#valid' do
    it { expect(user).to be_valid }

    context 'when without a name' do
      subject(:user) { FactoryGirl.build_stubbed(:user, name: nil) }

      it { expect(user).not_to be_valid }
    end
  end

  describe '#credit' do
    subject(:user) { FactoryGirl.create(:user) }

    let(:order) { FactoryGirl.create(:order, user: user) }
    let(:product_price) { FactoryGirl.create(:product_price, price_list: order.activity.price_list, amount: 1.23) }

    before do
      FactoryGirl.create(:order_row, order: order, product: product_price.product, product_count: 1)
    end

    it { expect(user.credit).to eq(-1.23) }
  end
end
