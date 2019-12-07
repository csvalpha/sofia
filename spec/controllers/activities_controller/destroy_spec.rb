require 'rails_helper'

describe ActivitiesController, type: :controller do
  describe 'DELETE destroy' do
    let(:activity) do
      FactoryBot.create(:activity, price_list: FactoryBot.create(:price_list))
    end
    let(:additional_records) { }
    let(:request) do
      delete :destroy, params: { id: activity.id }
    end

    before do
      additional_records

      sign_in user
      request
    end

    describe 'when without permission' do
      let(:user) { FactoryBot.create(:user) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as main bartender' do
      let(:user) { FactoryBot.create(:user, :main_bartender) }

      context 'when with empty activity' do
        it { expect(request.status).to eq 302 }
        it { expect(Activity.count).to eq 0 }
      end

      context 'when with non-empty activity' do
        let(:additional_records) { FactoryBot.create(:order, activity: activity) }

        it { expect(request.status).to eq 302 }
        it { expect(Activity.count).to eq 1 }
      end
    end

    describe 'when as treasurer' do
      let(:user) { FactoryBot.create(:user, :treasurer) }

      context 'when with empty activity' do
        it { expect(request.status).to eq 302 }
        it { expect(Activity.count).to eq 0 }
      end

      context 'when with non-empty activity' do
        let(:additional_records) { FactoryBot.create(:order, activity: activity) }

        it { expect(request.status).to eq 302 }
        it { expect(Activity.count).to eq 1 }
      end
    end
  end
end
