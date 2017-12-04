class OrdersController < ApplicationController
  before_action :set_model, only: %i[index new create]
  before_action :authenticate_user!

  after_action :verify_authorized

  def index
    authorize Order

    @product_prices = @activity.price_list.product_price.includes(:product)
    render layout: 'order_screen'
  end

  def new; end

  def create; end

  def model_class
    Order
  end

  private

  def set_model
    @activity = Activity.find_by(id: params[:activity_id])
  end

  def permitted_attributes
    params.require(:order).permit(%i[user order_row activity_id])
  end
end
