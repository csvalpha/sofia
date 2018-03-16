class OrdersController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized

  def index
    authorize Order

    render json: Order.includes(
      :order_rows, user: { orders: :order_rows }
    ).where(activity: permitted_attributes[:activity]).to_json(include: json_includes)
  end

  def create
    @order = Order.new(permitted_attributes.merge(created_by: current_user))
    authorize @order

    if @order.save
      render json: Order.includes(
        :order_rows, user: { orders: :order_rows }
      ).find(@order.id).to_json(include: json_includes)
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private

  def permitted_attributes
    params.require(:order).permit(%i[user_id paid_with_cash activity_id],
                                  order_rows_attributes: %i[id product_id product_count])
  end

  def json_includes
    { user: { only: %i[id name], methods: %i[credit avatar_thumb_or_default_url] },
      activity: { only: %i[id title] },
      order_rows: { only: [:id, :product_count, product: { only: %i[id name credit] }] } }
  end
end
