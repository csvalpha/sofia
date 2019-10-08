class OrdersController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized

  def index
    if allowed_filters.any?
      @orders = policy_scope(Order).where(allowed_filters).includes(:order_rows, :user, :activity)
    else
      render status: :bad_request
    end

    authorize @orders

    render json: @orders.to_json(proper_json)
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

  def update
    @order = Order.find(permitted_attributes_on_update[:id])

    authorize @order

    if @order.update(permitted_attributes_on_update)
      render json: @order.to_json(proper_json)
    else
      render json: @order.errors, status: :unprocessable_entity
    end
  end

  private

  def allowed_filters
    @allowed_filters ||= begin
      @allowed_filters = {}
      @allowed_filters[:activity] = params[:activity_id] if params[:activity_id]
      @allowed_filters[:user] = params[:user_id] if params[:user_id]
      @allowed_filters
    end
  end

  def permitted_attributes
    params.require(:order).permit(%i[user_id paid_with_cash paid_with_pin activity_id],
                                  order_rows_attributes: %i[id product_id product_count])
  end

  def permitted_attributes_on_update
    params.permit(:id, order_rows_attributes: %i[id product_count])
  end

  def proper_json
    { only: %i[id created_at order_total paid_with_cash paid_with_pin],
      include: { order_rows: {
        only: %i[id product_count price_per_product],
        include: { product: { only: %i[id name] } }
      }, user: { only: :name }, activity: { only: :title } } }
  end

  def json_includes
    { user: { only: %i[id name], methods: %i[credit avatar_thumb_or_default_url] },
      activity: { only: %i[id title] },
      order_rows: { only: [:id, :product_count, product: { only: %i[id name credit] }] } }
  end
end
