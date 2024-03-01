require 'rails_helper'

describe CreditMutationsController, type: :controller do
  
  describe 'GET index' do
    let(:credit_mutation) { create(:credit_mutation, user: create(:user)) }
    let(:credit_mutation_with_activity) { create(:credit_mutation, activity: create(:activity), user: create(:user)) } 
    let(:request) { get :index }

    before do
      credit_mutation
      credit_mutation_with_activity
      sign_in user
      request
    end

    describe 'when as treasurer' do
      let(:user) { create(:user, :treasurer) }

      it 'shows credit_mutations' do
        expect(request.status).to eq 200
        expect(assigns(:credit_mutations).size).to eq 2
      end
    end

    describe 'when as renting-manager' do
      let(:user) { create(:user, :renting_manager) }

      it 'shows credit_mutations' do
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe 'when as main-bartender' do
      let(:user) { create(:user, :main_bartender) }

      it 'shows credit_mutations' do
        expect(request.status).to eq 200
        expect(assigns(:credit_mutations).size).to eq 1
      end
    end

    describe 'when as user' do
      let(:user) { create(:user) }

      it 'shows credit_mutations' do
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
