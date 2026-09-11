require 'rails_helper'

describe ActivitiesController do
  describe 'POST create_invoices' do
    let(:activity) { create(:activity) }
    let(:request) do
      post :create_invoices, params: { id: activity.id }
    end

    it 'unauthenticated when without permission' do
      sign_in create(:user)
      request

      expect(request.status).to eq 403
    end

    it 'unauthenticated when as main-bartender' do
      sign_in create(:user, :main_bartender)
      request

      expect(request.status).to eq 403
    end

    it 'unauthenticated when as renting-manager' do
      sign_in create(:user, :renting_manager)
      request

      expect(request.status).to eq 403
    end

    context 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it 'enqueues invoice create job' do
        sign_in user
        activity.update(locked_by: create(:user))
        request

        expect(request.status).to eq 302
        expect(ActivityInvoiceJob).to have_been_enqueued
      end

      it 'unauthenticated when non-locked' do
        sign_in user
        request

        expect(request.status).to eq 403
      end
    end
  end
end
