require 'browser/aliases'
Browser::Base.include(Browser::Aliases)

class ActivitiesController < ApplicationController # rubocop:disable Metrics/ClassLength
  before_action :authenticate_user!
  after_action :verify_authorized, except: [:sumup_callback]
  after_action :verify_policy_scoped, only: :index

  def index # rubocop:disable Metrics/AbcSize
    authorize Activity
    @activities = policy_scope(Activity.includes(%i[price_list created_by]).order(start_time: :desc))

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

  def update
    @activity = Activity.find(params[:id])
    authorize @activity

    if @activity.update(params.require(:activity).permit(%i[title]))
      flash[:success] = 'Activiteit hernoemd'
    else
      flash[:error] = "Activiteit hernoemen mislukt; #{@activity.errors.full_messages.join(', ')}"
    end

    redirect_to @activity
  end

  def destroy
    @activity = Activity.find(params[:id])
    authorize @activity

    if @activity.destroy
      flash[:success] = 'Activiteit verwijderd'
    else
      flash[:error] = "Activiteit verwijderen mislukt; #{@activity.errors.full_messages.join(', ')}"
    end

    redirect_to Activity
  end

  def show # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @activity = Activity.includes(:price_list,
                                  { orders: [{ order_rows: :product }, :user, :created_by] },
                                  credit_mutations: [:user]).find(params[:id])
    authorize @activity

    @price_list = @activity.price_list
    @bartenders = @activity.bartenders
    @orders = @activity.orders

    @credit_mutations = @activity.credit_mutations
    @credit_mutations_total = @activity.credit_mutations_total

    @revenue_by_category = @activity.revenue_by_category
    @revenue_with_cash = @activity.revenue_with_cash
    @revenue_with_pin = @activity.revenue_with_pin
    @revenue_with_credit = @activity.revenue_with_credit
    @cash_total = @activity.cash_total
    @revenue_total = @activity.revenue_total

    @count_per_product = @activity.count_per_product
  end

  def order_screen # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    authorize Activity

    @activity = Activity.includes([:price_list, price_list: { product_price: :product }])
                        .find(params[:id])

    @product_prices_json = sorted_product_price(@activity).to_json(
      include: { product: { only: %i[id name category], methods: %i[requires_age] } }
    )

    @users_json = users_hash.to_json

    @activity_json = @activity.to_json(only: %i[id title start_time end_time])

    is_mobile = Browser.new(request.user_agent).mobile?
    @sumup_key = Rails.application.config.x.sumup_key
    @sumup_enabled = is_mobile && @sumup_key.present? || false

    # Set flags for application.html.slim
    @show_navigationbar = false
    @show_extras = false
  end

  def product_totals
    authorize Activity

    activity = Activity.includes(:price_list, orders: [{ order_rows: :product }, :user]).find(params[:id])
    render json: activity.count_per_product(**params.permit(:user, :paid_with_pin, :paid_with_cash).to_h.symbolize_keys)
  end

  def sumup_callback
    if params['smp-status'] == 'success'
      flash[:success] = 'Pinbetaling is gelukt!'
    else
      flash[:error] = "Pinbetaling is mislukt! De bestelling is echter ingevoerd.
                        Zorg dat de betaling (op een andere manier) lukt of verwijderd de bestelling handmatig uit het systeem."
    end

    redirect_to order_screen_activity_path
  end

  def lock
    activity = Activity.find(params[:id])
    authorize activity

    activity.locked_by = current_user

    if activity.save
      flash[:success] = 'Activiteit is succesvol vergrendeld'
    else
      flash[:error] = activity.errors.full_messages.join(', ')
    end

    redirect_to activity
  end

  private

  def users_hash
    users_credits = User.calculate_credits
    User.order(:name).map do |user|
      hash = user.attributes
      hash[:minor] = user.minor
      hash[:avatar_thumb_or_default_url] = user.avatar_thumb_or_default_url
      hash[:credit] = users_credits.fetch(user.id, 0)
      hash
    end
  end

  def sorted_product_price(activity)
    activity.price_list.product_price.sort_by { |p| p.product.id }
  end

  def permitted_attributes
    params.require(:activity).permit(%i[title start_time end_time price_list_id])
  end
end
