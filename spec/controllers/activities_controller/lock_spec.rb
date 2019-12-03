require 'rails_helper'

describe ActivitiesController, type: :controller do
  describe 'POST lock' do
    let(:activity) { FactoryBot.create(:activity) }
    let(:request) do
      post :lock, params: { id: activity.id }
    end

    it 'unauthenticated when without permission' do
      sign_in FactoryBot.create(:user)
      request

      expect(request.status).to eq 403
    end

    it 'unauthenticated when as main-bartender' do
      sign_in FactoryBot.create(:user, :main_bartender)
      request

      expect(request.status).to eq 403
    end

    context 'when as treasurer' do
      let(:user) { FactoryBot.create(:user, :treasurer) }

      it 'locks the activity' do
        sign_in user
        request
        activity.reload

        expect(request.status).to eq 302
        expect(activity.locked_by).to eq user
      end

      it 'unauthenticated when already locked' do
        sign_in user
        activity.locked_by = FactoryBot.create(:user)
        activity.save
        request

        expect(request.status).to eq 403
      end
    end
  end
end
