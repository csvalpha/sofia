require 'rails_helper'

describe ActivitiesController, type: :controller do
  describe 'DELETE destroy' do
    let(:activity) do
      create(:activity, price_list: create(:price_list))
    end
    let(:additional_records) { [] }
    let(:request) do
      delete :destroy, params: { id: activity.id }
    end

    before do
      additional_records

      sign_in user
      request
    end

    describe 'when without permission' do
      let(:user) { create(:user) }

      it { expect(request.status).to eq 403 }
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }

      context 'when with empty activity' do
        it { expect(request.status).to eq 302 }
        it { expect(Activity.count).to eq 0 }
      end

      context 'when with non-empty activity' do
        let(:additional_records) { create(:order, activity:) }

        it { expect(request.status).to eq 302 }
        it { expect(Activity.count).to eq 1 }
      end
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      context 'when with empty activity' do
        it { expect(request.status).to eq 302 }
        it { expect(Activity.count).to eq 0 }
      end

      context 'when with non-empty activity' do
        let(:additional_records) { create(:order, activity:) }

        it { expect(request.status).to eq 302 }
        it { expect(Activity.count).to eq 1 }
      end
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      context 'when with empty activity' do
        it { expect(request.status).to eq 302 }
        it { expect(Activity.count).to eq 0 }
      end

      context 'when with non-empty activity' do
        let(:additional_records) { create(:order, activity:) }

        it { expect(request.status).to eq 302 }
        it { expect(Activity.count).to eq 1 }
      end
    end
  end
end
