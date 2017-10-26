class OrdersController < ApplicationController
  before_action :set_model, only: %i[show update destroy]
  before_action :authenticate_user!

  def index
    render layout: 'order_screen'
  end

  def new; end

  def create; end

  def model_class
    Order
  end

  private

  def permitted_attributes
    params.require(:order).permit(%i[user order_row])
  end
end
