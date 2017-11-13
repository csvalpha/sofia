class PriceListsController < ApplicationController
  before_action :set_model, only: %i[show update destroy]
  before_action :authenticate_user!

  autocomplete :price_list, :name, full: true

  def index
    recent_price_lists = PriceList.limit(6)
    products = Product.all.order(:id).includes(:product_prices)

    @recent_price_lists_json = recent_price_lists.to_json(except: %i[created_at updated_at deleted_at])
    @products_json = products.to_json(include: { product_prices: { except: %i[created_at updated_at deleted_at] } },
                                      except: %i[created_at updated_at deleted_at])
  end

  def update
    render json: @model if @model.update(permitted_attributes)
  end

  def model_class
    PriceList
  end

  private

  def permitted_attributes
    params.require(:price_list).permit(:name)
  end
end
