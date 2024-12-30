require 'rails_helper'

describe CreditMutationsController, type: :controller do
  describe 'POST create' do
    let(:user) { create(:user) }
    let(:credit_mutation) do
      build(:credit_mutation, user: user)
    end
    let(:credit_mutation_with_activity) do
      build(:credit_mutation, activity: create(:activity), user: user)
    end
    let(:request1) do
      post :create, params: { credit_mutation: credit_mutation.attributes, format: :json }
    end
    let(:request2) do
      post :create, params: { credit_mutation: credit_mutation_with_activity.attributes, format: :json }
    end

    context 'when as treasurer' do
      it 'creates a new credit_mutation' do
        sign_in create(:user, :treasurer)
        expect { request1 }.to(change(CreditMutation, :count).by(1))
      end

      it 'creates a new credit_mutation linked to an activity' do
        sign_in create(:user, :treasurer)
        expect { request2 }.to(change(CreditMutation, :count).by(1))
      end
    end

    context 'when as renting-manager' do
      it 'creates a new credit_mutation' do
        sign_in create(:user, :renting_manager)
        expect { request1 }.not_to change(CreditMutation, :count)
      end

      it 'creates a new credit_mutation linked to an activity' do
        sign_in create(:user, :renting_manager)
        expect { request2 }.not_to change(CreditMutation, :count)
      end
    end

    context 'when as main-bartender' do
      it 'creates a new credit_mutation' do
        sign_in create(:user, :main_bartender)
        expect { request1 }.not_to change(CreditMutation, :count)
      end

      it 'creates a new credit_mutation linked to an activity' do
        sign_in create(:user, :main_bartender)
        expect { request2 }.to(change(CreditMutation, :count).by(1))
      end
    end

    context 'when as user' do
      it 'creates a new credit_mutation' do
        sign_in create(:user)
        expect { request1 }.not_to change(CreditMutation, :count)
      end

      it 'creates a new credit_mutation linked to an activity' do
        sign_in create(:user)
        expect { request2 }.not_to change(CreditMutation, :count)
      end
    end
  end
end
