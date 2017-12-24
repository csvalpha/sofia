class OrdersController < ApplicationController
  before_action :set_model, only: %i[index new create]

  def index
    authorize model_class

    @product_prices = @activity.price_list.product_price.includes(:product)
    render layout: 'order_screen'
  end

  def new; end

  def create; end

  private

  def set_model
    @activity = Activity.find_by(id: params[:activity_id])
  end

  def model_params
    %i[user order_row activity_id]
  end
end
