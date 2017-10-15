class ProductPriceController < ApplicationController
  before_action :set_model, only: %i[show update]
  before_action :authenticate_user!

  def show
    render json: @model
  end

  def update
    if @model.update(permitted_attributes)
      render json: @model
    else
      respond_bip_error(@model)
    end
  end

  def model_class
    ProductPrice
  end

  private

  def permitted_attributes
    params.require(:product_price).permit(:amount)
  end
end
