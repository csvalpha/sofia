class ActivitiesController < ApplicationController
  before_action :set_model, only: %i[show update destroy]

  def index
    @model = records.includes(model_includes)
    @new_activity = Activity.new
  rescue ActiveModel::RangeError
    head :not_found
  end

  def create
    binding.pry
    @activity = Activity.new(permitted_attributes)
    if @activity.save
      redirect_to activities_url, notice: "Successfully created activity."
    else
      render :index
    end
  end

  def model_class
    Activity
  end

  private
  def permitted_attributes
    params.require(:activity).permit([:title, :start_time, :end_time, :price_list_id])
  end
end
