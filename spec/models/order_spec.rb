require 'rails_helper'

RSpec.describe Order do
  subject(:order) { build_stubbed(:order) }

  describe '#valid' do
    it { expect(order).to be_valid }

    context 'when without user and without paid_with_cash' do
      subject(:order) { build_stubbed(:order, user: nil) }

      it { expect(order).not_to be_valid }
    end

    context 'when without user with paid_with_cash' do
      subject(:order) { build_stubbed(:order, user: nil, paid_with_cash: true) }

      it { expect(order).to be_valid }
    end

    context 'when without activity' do
      subject(:order) { build_stubbed(:order, activity: nil) }

      it { expect(order).not_to be_valid }
    end

    context 'when without created by' do
      subject(:order) { build_stubbed(:order, created_by: nil) }

      it { expect(order).not_to be_valid }
    end

    context 'when with locked activity' do
      let(:activity) { build_stubbed(:activity, :locked) }
      let(:order) { build(:order, activity:) }

      it { expect(order).not_to be_valid }
    end
  end

  describe '#order_total' do
    context 'when without rows' do
      subject(:order) { create(:order) }

      it { expect(order.order_total).to eq 0 }
    end

    context 'when with one row' do
      let(:product) { create(:product) }
      let(:price_list) { create(:price_list, :with_products, products: [product]) }

      let(:activity) { create(:activity, price_list:) }

      subject(:order) { create(:order, activity:) }

      before do
        create(:order_row, order:, product:, product_count: 2)
        order.reload
      end

      it { expect(order.order_total).to eq(2 * price_list.product_price_for(product).price) }
    end
  end

  describe '#count_per_product' do
    let(:product_a) { create(:product, name: 'A') }
    let(:product_b) { create(:product, name: 'B') }
    let(:price_list) { create(:price_list, :with_products, products: [product_a, product_b]) }
    let(:activity) { create(:activity, price_list:) }
    let(:order) { create(:order, activity:) }
    let(:to_new_order) { create(:order, activity:, created_at: 11.days.from_now) }

    subject(:count) { described_class.count_per_product(10.days.ago, 10.days.from_now) }

    before do
      create_list(:order_row, 2, order:, product: product_a, product_count: 2)
      create_list(:order_row, 3, order:, product: product_b, product_count: 3)
      create_list(:order_row, 3, order: to_new_order, product: product_b, product_count: 3)
    end

    it { expect(count.find { |item| item[:name] == 'A' }[:amount]).to eq 4 }
    it { expect(count.find { |item| item[:name] == 'B' }[:amount]).to eq 9 }
  end

  describe '#count_per_category' do
    let(:product_a) { create(:product, name: 'A', category: 'beer') }
    let(:product_b) { create(:product, name: 'B', category: 'wine') }
    let(:price_list) { create(:price_list, :with_products, products: [product_a, product_b]) }
    let(:activity) { create(:activity, price_list:) }
    let(:order) { create(:order, activity:) }
    let(:to_new_order) { create(:order, activity:, created_at: 11.days.from_now) }

    subject(:count) { described_class.count_per_category(10.days.ago, 10.days.from_now) }

    before do
      create_list(:order_row, 2, order:, product: product_a, product_count: 2)
      create_list(:order_row, 3, order:, product: product_b, product_count: 3)
      create_list(:order_row, 3, order: to_new_order, product: product_b, product_count: 3)
    end

    it { expect(count.find { |item| item[:category] == 'beer' }[:amount]).to eq 4 }
    it { expect(count.find { |item| item[:category] == 'wine' }[:amount]).to eq 9 }
  end

  describe '#create' do
    let(:activity) { create(:activity) }

    context 'when no user' do
      let(:order) { build(:order, paid_with_cash: true, activity:) }

      it { expect(order.save).to be true }
    end

    context 'when non-amber user without credit' do
      let(:user) { create(:user) }
      let(:order) { build(:order, user:, activity:) }

      before do
        create(:credit_mutation, user:, amount: -1)
      end

      it { expect(order.save).to be true }
    end

    context 'when amber user' do
      let(:user) { create(:user, provider: 'amber_oauth2') }
      let(:order) { build(:order, user:, activity:) }

      context 'with credit' do
        # Note that a credit of 0 counts as non-negative credit
        it { expect(order.save).to be true }
      end

      context 'without credit with activity order' do
        before do
          create(:order, user:, activity:)
          create(:credit_mutation, user:, amount: -1)
        end

        it { expect(order.save).to be true }
      end

      context 'without credit without activity order' do
        before do
          create(:credit_mutation, user:, amount: -1)
        end

        it { expect(order.save).to be false }
      end
    end
  end

  describe '#destroy' do
    let(:order) { create(:order) }

    it { expect(order.destroy).to be false }
  end
end
