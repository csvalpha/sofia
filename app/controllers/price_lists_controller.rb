class PriceListsController < ApplicationController
  before_action :set_model, only: %i[show update destroy]
  before_action :authenticate_user!

  autocomplete :price_list, :name, full: true

  def index
    @recent_price_lists = PriceList.limit(6).includes([:product_price, :products, { product_price: :product }])
    @products = Product.all.includes(:product_price)
    @product_price = @recent_price_lists.map(&:product_price).flatten.uniq
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
