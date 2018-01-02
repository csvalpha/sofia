class ActivitiesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index # rubocop:disable Metrics/AbcSize
    @activities = Activity.includes([:price_list])
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
    @activity = Activity.includes([:price_list, orders: %i[user order_rows]]).find(params[:id])

    authorize @activity
  end

  private

  def permitted_attributes
    params.require(:activity).permit(%i[title start_time end_time price_list_id])
  end
end
