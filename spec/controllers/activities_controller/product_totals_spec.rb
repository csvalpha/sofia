require 'rails_helper'

describe ActivitiesController, type: :controller do
  describe 'GET product_totals' do
    let(:activity) { FactoryBot.create(:activity) }
    let(:params) { { id: activity.id } }
    let(:request) { get :product_totals, params: params }
    let(:order) { FactoryBot.create(:order, activity: activity)}
    let(:unbound_order) { FactoryBot.create(:order, activity: activity)}
    let(:products) { activity.price_list.products.sample(2) }

    before do
      activity
      FactoryBot.create(:order_row, order: order, product_count: 2, product: products.first)
      FactoryBot.create(:order_row, order: order, product_count: 3, product: products.last)
      FactoryBot.create(:order_row, order: unbound_order, product_count: 4, product: products.first)


      sign_in user
      request
    end

    describe 'when without permissions' do
      let(:user) { FactoryBot.create(:user) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as main-bartender' do
      let(:user) { FactoryBot.create(:user, :main_bartender) }

      it do
        expect(request.status).to eq 200
        expect(activity.count_per_product.find { |item| item[:name] == products.first[:name] }[:amount]).to eq 6
        expect(activity.count_per_product.find { |item| item[:name] == products.last[:name] }[:amount]).to eq 3
      end
    end

    describe 'when as treasurer' do
      let(:user) { FactoryBot.create(:user, :treasurer) }

      it do
        expect(request.status).to eq 200
        expect(activity.count_per_product.find { |item| item[:name] == products.first[:name] }[:amount]).to eq 6
        expect(activity.count_per_product.find { |item| item[:name] == products.last[:name] }[:amount]).to eq 3
      end

      context 'when filtering for user' do
        let(:order) { FactoryBot.create(:order, activity: activity, user: user)}
        let(:params) { {id: activity.id, user: user.id } }

        it do
          expect(activity.count_per_product.find { |item| item[:name] == products.first[:name] }[:amount]).to eq 2
          expect(activity.count_per_product.find { |item| item[:name] == products.last[:name] }[:amount]).to eq 3
        end
      end
    end
  end
end
