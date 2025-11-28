require 'rails_helper'

describe ActivitiesController do
  describe 'PUT update' do
    let(:activity) do
      create(:activity, price_list: create(:price_list))
    end
    let(:request) do
      put :update, params: { id: activity.id, activity: activity.attributes }
    end

    before do
      sign_in user
      activity.title = 'New Title'
      request
      activity.reload
    end

    describe 'when without permission' do
      let(:user) { create(:user) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }

      it { expect(request.status).to eq 302 }
      it { expect(activity.title).to eq 'New Title' }
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      it { expect(request.status).to eq 302 }
      it { expect(activity.title).to eq 'New Title' }
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it { expect(request.status).to eq 302 }
      it { expect(activity.title).to eq 'New Title' }
    end
  end
end
