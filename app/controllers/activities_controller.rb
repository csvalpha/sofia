class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index # rubocop:disable Metrics/AbcSize
    @activities = Activity.includes(%i[price_list created_by]).order(start_time: :desc)
    authorize @activities

    @activity = Activity.new(
      start_time: (Time.zone.now + 2.hours).beginning_of_hour,
      end_time: (Time.zone.now + 6.hours).beginning_of_hour
    )

    @price_lists_json = PriceList.all.to_json(only: %i[id name])
  end

  def create
    @activity = Activity.new(permitted_attributes.merge(created_by: current_user))
    authorize @activity

    if @activity.save
      flash[:success] = 'Successfully created activity'
    else
      flash[:error] = @activity.errors.full_messages.join(', ')
    end

    redirect_to activities_url
  end

  def show
    @activity = Activity.includes(:price_list,
                                  { orders: [{ order_rows: :product }, :user, :created_by] },
                                  credit_mutations: [:user]).find(params[:id])

    authorize @activity
  end

  def order_screen
    authorize Activity

    @activity = Activity.includes([:price_list, price_list: { product_price: :product }])
                        .find(params[:id])

    @product_prices_json = sorted_product_price(@activity).to_json(include: { product: { only: %i[id name category] } })

    @users_json = User.includes(%i[credit_mutations order_rows]).order(:name)
                      .to_json(only: %i[id name], methods: %i[credit avatar_thumb_or_default_url])
    @activity_json = @activity.to_json(only: %i[id title start_time end_time])

    render layout: 'order_screen'
  end

  private

  def sorted_product_price(activity)
    activity.price_list.product_price.sort_by { |p| p.product.id }
  end

  def permitted_attributes
    params.require(:activity).permit(%i[title start_time end_time price_list_id])
  end
end
