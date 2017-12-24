class PriceListsController < ApplicationController
  def index
    recent_price_lists = PriceList.order(created_at: :desc).limit(5)
    products = Product.all.order(:id).includes(:product_prices)

    authorize recent_price_lists

    @new_model = PriceList.new

    @recent_price_lists_json = recent_price_lists.to_json(except: %i[created_at updated_at deleted_at])
    @products_json = products.to_json(include: { product_prices: { except: %i[created_at updated_at deleted_at] } },
                                      except: %i[created_at updated_at deleted_at])
  end

  def search
    authorize PriceList

    @price_lists = PriceList.where('lower(name) LIKE ?', "%#{params[:query]&.downcase}%")

    render json: @price_lists
  end

  private

  def model_includes
    [:product_price, :activities, product_price: :product]
  end

  def model_params
    [:name]
  end
end
