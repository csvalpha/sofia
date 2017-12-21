class OrdersController < ApplicationController
  before_action :set_model, only: %i[index new create]
  before_action :authenticate_user!

  after_action :verify_authorized

  def index
    authorize Order

    @activity = Activity.includes([:price_list, price_list: { product_price: :product }])
                        .find(params[:activity_id])

    @product_prices_json = @activity.price_list.product_price
                                    .to_json(include: {
                                               product: { except: %i[created_at updated_at deleted_at] }
                                             }, except: %i[created_at updated_at])

    @users_json = User.includes([:orders, :credit_mutations, orders: :order_rows])
                      .to_json(only: %i[name id], methods: :credit)
    @activity_json = @activity.to_json(only: %i[title start_time end_time])

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
