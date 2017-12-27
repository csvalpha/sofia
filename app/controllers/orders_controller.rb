class OrdersController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized

  def index
    authorize Order

    @activity = Activity.includes([:price_list, price_list: { product_price: :product }])
                        .find(params[:activity_id])

    @product_prices_json = @activity.price_list.product_price
                                    .to_json(include: { product: { only: %i[id name requires_age] } })

    @users_json = User.includes([:orders, :credit_mutations, orders: :order_rows])
                      .to_json(only: %i[name id], methods: :credit)
    @activity_json = @activity.to_json(only: %i[title start_time end_time])

    render layout: 'order_screen'
  end

  private

  def permitted_attributes
    params.require(:order).permit(%i[user order_row activity_id])
  end
end
