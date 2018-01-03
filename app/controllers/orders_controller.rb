class OrdersController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized

  def index
    authorize Order

    @activity = Activity.includes([:price_list, price_list: { product_price: :product }])
                        .find(params[:activity_id])

    @product_prices_json = @activity.price_list.product_price
                                    .to_json(include: { product: { only: %i[id name requires_age] } })

    @users_json = User.includes(%i[credit_mutations order_rows])
                      .to_json(only: %i[id name], methods: :credit)
    @activity_json = @activity.to_json(only: %i[id title start_time end_time])

    render layout: 'order_screen'
  end

  def create
    @order = Order.new(permitted_attributes)
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
    params.require(:order).permit(%i[user_id activity_id], order_rows_attributes: %i[id product_id product_count])
  end

  def json_includes
    { user: { only: %i[id name], methods: :credit },
      activity: { only: %i[id title] },
      order_rows: { only: [:id, :product_count, product: { only: %i[id name credit] }] } }
  end
end
