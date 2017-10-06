class ActivitiesController < ApplicationController
  before_action :set_model, only: %i[show update destroy]

  def index
    @new_activity = Activity.new
    super
  end

  def create
    @activity = Activity.new(permitted_attributes)
    if @activity.save
      redirect_to activities_url, notice: 'Successfully created activity.'
    else
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
