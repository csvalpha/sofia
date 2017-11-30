class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_model, only: %i[update]

  def model_class
    raise NotImplementedError
  end

  def index
    @model = records.includes(model_includes)
  rescue ActiveModel::RangeError
    head :not_found
  end

  private

  def set_model
    @model = model_class.includes(model_includes).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    head :not_found
  end

  def records
    @objects ||= model_class.all
  end

  def model_includes
    []
  end
end
