class ActivitiesController < ApplicationController
  before_action :set_model, only: %i[show update destroy]
  before_action :authenticate_user!

  def index
    @activity = Activity.new(
      start_time: (Time.zone.now + 2.hours).beginning_of_hour,
      end_time: (Time.zone.now + 6.hours).beginning_of_hour
    )
    @model = Activity.includes(model_includes)
  end

  def create
    @activity = Activity.new(permitted_attributes)
    if @activity.save
      redirect_to activities_url, notice: 'Successfully created activity.'
    else
      @model = Activity.includes(model_includes)
      render :index
    end
  end

  def model_class
    Activity
  end

  def model_includes
    [:price_list, orders: :user]
  end

  private

  def permitted_attributes
    params.require(:activity).permit(%i[title start_time end_time price_list_id])
  end
end
