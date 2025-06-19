require 'rails_helper'

describe InvoicesController do
  describe 'POST create' do
    let(:invoice) do
      build(:invoice, user: create(:user), activity: create(:activity, :locked))
    end
    let(:request) do
      post :create, params: { invoice: invoice.attributes }
    end

    it 'treasurer creates a new invoice' do
      sign_in create(:user, :treasurer)
      expect { request }.to(change(Invoice, :count).by(1))
    end

    it 'renting-manager cannot create a new invoice' do
      sign_in create(:user, :renting_manager)
      expect { request }.not_to change(Invoice, :count)
    end

    it 'main-bartender cannot create a new invoice' do
      sign_in create(:user, :main_bartender)
      expect { request }.not_to change(Invoice, :count)
    end

    it 'user cannot create a new invoice' do
      sign_in create(:user)
      expect { request }.not_to change(Invoice, :count)
    end

    it 'redirects after create' do
      sign_in create(:user, :treasurer)
      request
      expect(response).to be_redirect
    end
  end
end
