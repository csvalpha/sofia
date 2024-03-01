require 'rails_helper'

describe PriceListsController, type: :controller do
  
  describe 'GET index' do
    let(:archived_price_lists) { create_list(:price_list, 3, :archived) }
    let(:unarchived_price_lists) { create_list(:price_list, 3) }

    before do
      archived_price_lists
      unarchived_price_lists
    end

    context 'when as treasurer' do
      it 'shows all price_lists' do
        sign_in create(:user, :treasurer)
        get :index

        expect(assigns(:price_lists_json)).to eq PriceList.all.order(created_at: :desc).to_json(except: %i[created_at updated_at deleted_at])
      end
    end

    context 'when as renting-manager' do
      it 'shows unarchived price_lists' do
        sign_in create(:user, :renting_manager)
        get :index

        expect(assigns(:price_lists_json)).to eq PriceList.unarchived.order(created_at: :desc).to_json(except: %i[created_at updated_at deleted_at])
      end
    end

    context 'when as main-bartender' do
      it 'shows unarchived price_lists' do
        sign_in create(:user, :main_bartender)
        get :index

        expect(assigns(:price_lists_json)).to eq PriceList.unarchived.order(created_at: :desc).to_json(except: %i[created_at updated_at deleted_at])
      end
    end

    context 'when as user' do
      it 'forbids' do
        sign_in create(:user)
        get :index

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end
