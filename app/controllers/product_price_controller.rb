class ProductPriceController < ApplicationController
  before_action :model, only: %i[destroy]
  before_action :authenticate_user!

  after_action :verify_authorized

  def destroy
    authorize @model

    @model.destroy
    head :no_content
  end

  private

  def model
    @model ||= ProductPrice.find(params[:id])
  end

  def permitted_attributes
    params.require(:product_price).permit(:price)
  end
end
