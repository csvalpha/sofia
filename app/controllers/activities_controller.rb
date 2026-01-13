require 'browser/aliases'
Browser::Base.include(Browser::Aliases)

class ActivitiesController < ApplicationController # rubocop:disable Metrics/ClassLength
  include ActionView::Helpers::TextHelper

  before_action :authenticate_user!
  after_action :verify_authorized, except: [:sumup_callback]
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Activity
    @activities = policy_scope(Activity.includes(%i[price_list created_by locked_by])
                                   .order(start_time: :desc)
                                   .page(params[:page]))

    @activity = Activity.new(
      start_time: 2.hours.from_now.beginning_of_hour,
      end_time: 6.hours.from_now.beginning_of_hour
    )

    @price_lists_json = PriceList.unarchived.to_json(only: %i[id name])
  end

  def show # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    @activity = Activity.includes(:price_list,
                                  { orders: [{ order_rows: :product }, :user, :created_by] }).find(params[:id])
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

  def create
    @activity = Activity.new(activity_params.merge(created_by: current_user))
    authorize @activity

    if @activity.save
      flash[:success] = 'Activiteit aangemaakt'
    else
      flash[:error] = @activity.errors.full_messages.join(', ')
    end

    redirect_to activities_url
  end

  def update
    @activity = Activity.find(params[:id])
    authorize @activity

    if @activity.update(activity_params_for_update)
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

  def order_screen # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    authorize Activity

    @activity = Activity.includes([:price_list, { price_list: { product_price: :product } }])
                        .find(params[:id])

    @product_prices_json = sorted_product_price(@activity).to_json(
      include: { product: { only: %i[id name category color], methods: %i[requires_age] } }
    )

    @users_json = users_hash.to_json

    @activity_json = @activity.to_json(only: %i[id title start_time end_time])

    @sumup_key = Rails.application.config.x.sumup_key
    @sumup_enabled = @sumup_key.present?

    if params['sumup_error']
      sumup_order_id = params['sumup_error'].split('-').first
      sumup_attempt = if params['sumup_error'].include? '-'
                        params['sumup_error'].split('-').last.to_i
                      else
                        0
                      end
      @sumup_error_order = Order.find(sumup_order_id)
      @sumup_tx_id = "#{sumup_order_id}-#{sumup_attempt + 1}"
    else
      @sumup_error_order = false
    end

    # Set flags for application.html.slim
    @show_navigationbar = false
    @show_extras = false
  end

  def product_totals
    authorize Activity

    permitted_params = params.permit(:id, :user, :paid_with_pin, :paid_with_cash)
    activity = Activity.includes(:price_list, orders: [{ order_rows: :product }, :user]).find(permitted_params[:id])
    render json: activity.count_per_product(**permitted_params.except(:id).to_h.symbolize_keys)
  end

  def sumup_callback
    if params['smp-status'] == 'success'
      flash[:success] = 'Pinbetaling is gelukt!'

      redirect_to order_screen_activity_path
    else
      redirect_to order_screen_activity_path(sumup_error: params['foreign-tx-id'])
    end
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

  def create_invoices
    activity = Activity.find(params[:id])
    authorize activity

    ActivityInvoiceJob.perform_later(activity)

    flash[:success] = "#{pluralize(activity.manually_added_users_with_orders.size, 'factuur', plural: 'facturen')}
                        aangemaakt! Verstuur deze via 'Facturen'"
    redirect_to activity
  end

  private

  def users_hash
    users_credits = User.calculate_credits
    User.active.order(:name).map do |user|
      user.current_activity = @activity
      user.as_json(methods: %i[avatar_thumb_or_default_url minor insufficient_credit can_order])
          .merge(credit: users_credits.fetch(user.id, 0))
    end
  end

  def sorted_product_price(activity)
    activity.price_list.product_price.sort_by { |p| p.product.id }
  end

  def activity_params
    params.require(:activity).permit(policy(Activity).permitted_attributes)
  end

  def activity_params_for_update
    params.require(:activity).permit(policy(@activity).permitted_attributes_for_update)
  end
end
