require 'rails_helper'

describe PaymentsController, type: :controller do
  describe 'GET index' do
    let(:payments) { FactoryBot.create_list(:payment, 2) }

    before do
      payments
    end

    context 'when as treasurer' do
      it 'shows payment' do
        sign_in FactoryBot.create(:user, :treasurer)
        get :index

        expect(assigns(:payments).size).to eq payments.size
      end
    end

    context 'when as user' do
      it 'forbids' do
        sign_in FactoryBot.create(:user)
        get :index

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
