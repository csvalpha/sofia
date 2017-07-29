class ActivitiesController < ApplicationController
  before_action :set_model, only: %i[show update destroy]

  def index
    @activities = records.includes(model_includes)
  rescue ActiveModel::RangeError
    head :not_found
  end

  def show
  end

  def model_class
    Activity
  end
end
