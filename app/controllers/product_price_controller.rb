class ProductPriceController < ApplicationController
  before_action :set_model, only: %i[show update destroy]
  before_action :authenticate_user!

  after_action :verify_authorized

  def destroy
    authorize @model

    @model.destroy
    head :no_content
  end

  private

  def set_model
    @model ||= ProductPrice.find(params[:id])
  end

  def permitted_attributes
    params.require(:product_price).permit(:price)
  end
end
