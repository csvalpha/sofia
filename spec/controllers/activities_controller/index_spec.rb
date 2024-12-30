require 'rails_helper'

describe ActivitiesController, type: :controller do
  describe 'GET index' do
    let(:unlocked_activities) { create(:activity) }
    let(:locked_activities) { create_list(:activity, 2, :locked) }
    let(:price_lists) { create_list(:price_list, 3) }
    let(:request) { get :index }

    before do
      unlocked_activities
      locked_activities
      price_lists
      sign_in user
      request
    end

    describe 'when without permissions' do
      let(:user) { create(:user) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }

      it do
        expect(request.status).to eq 200
        expect(assigns(:activities).size).to eq 1
        expect(assigns(:price_lists_json)).to eq PriceList.all.to_json(only: %i[id name])
        expect(assigns(:activity)).to be_an_instance_of(Activity)
      end
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      it do
        expect(request.status).to eq 200
        expect(assigns(:activities).size).to eq 3
        expect(assigns(:price_lists_json)).to eq PriceList.all.to_json(only: %i[id name])
        expect(assigns(:activity)).to be_an_instance_of(Activity)
      end
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it do
        expect(request.status).to eq 200
        expect(assigns(:activities).size).to eq 3
        expect(assigns(:price_lists_json)).to eq PriceList.all.to_json(only: %i[id name])
        expect(assigns(:activity)).to be_an_instance_of(Activity)
      end
    end
  end
end
