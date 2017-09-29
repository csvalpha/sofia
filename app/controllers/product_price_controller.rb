class ProductPriceController < ApplicationController
  before_action :set_model, only: %i[show update]

  def show
    render json: @model
  end

  def update
    if @model.update(permitted_attributes)
      render json: @mode
    else
      respond_with_errors(@model)
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
