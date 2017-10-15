class PriceListsController < ApplicationController
  before_action :set_model, only: %i[show update destroy]
  before_action :authenticate_user!

  autocomplete :price_list, :name, full: true

  def index
    @recent_price_lists = PriceList.order(:created_at).limit(6).includes(model_includes) || []
    @products = @recent_price_lists.map(&:products).flatten.uniq.sort_by(&:created_at)
  end

  def update
    if @model.update(permitted_attributes)
      render json: @model
    else
      respond_bip_error(@model)
    end
  end

  def model_class
    PriceList
  end

  def model_includes
    [:product_price, product_price: :product]
  end

  private

  def permitted_attributes
    params.require(:price_list).permit(:name)
  end
end
