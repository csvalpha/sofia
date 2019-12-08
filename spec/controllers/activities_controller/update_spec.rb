require 'rails_helper'

describe ActivitiesController, type: :controller do
  describe 'PUT update' do
    let(:activity) do
      FactoryBot.create(:activity, price_list: FactoryBot.create(:price_list))
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
      let(:user) { FactoryBot.create(:user) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as main-bartender' do
      let(:user) { FactoryBot.create(:user, :main_bartender) }

      it { expect(request.status).to eq 302 }
      it { expect(activity.title).to eq 'New Title' }
    end

    describe 'when as treasurer' do
      let(:user) { FactoryBot.create(:user, :treasurer) }

      it { expect(request.status).to eq 302 }
      it { expect(activity.title).to eq 'New Title' }
    end
  end
end
