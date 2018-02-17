class OrdersController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized

  def index
    authorize Order

    @activity = Activity.includes([:price_list, price_list: { product_price: :product }])
                        .find(params[:activity_id])

    @product_prices_json = sorted_product_price(@activity).to_json(include: { product: { only: %i[id name category requires_age] } })

    @users_json = User.includes(%i[credit_mutations order_rows]).order(:name)
                      .to_json(only: %i[id name], methods: %i[credit minor_age avatar_thumb_or_default_url])
    @activity_json = @activity.to_json(only: %i[id title start_time end_time])

    render layout: 'order_screen'
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

  def sorted_product_price(activity)
    activity.price_list.product_price.sort_by { |p| p.product.id }
  end

  def permitted_attributes
    params.require(:order).permit(%i[user_id activity_id], order_rows_attributes: %i[id product_id product_count])
  end

  def json_includes
    { user: { only: %i[id name], methods: %i[credit avatar_thumb_or_default_url] },
      activity: { only: %i[id title] },
      order_rows: { only: [:id, :product_count, product: { only: %i[id name credit] }] } }
  end
end
