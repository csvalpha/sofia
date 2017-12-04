class ProductPriceController < ApplicationController
  before_action :set_model, only: %i[show update]
  before_action :authenticate_user!

  after_action :verify_authorized

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

  private

  def permitted_attributes
    params.require(:product_price).permit(:price)
  end
end
