class ApplicationController < ActionController::Base
  include Pundit
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_action :set_model, only: %i[show update destroy]
  after_action :verify_authorized

  def index
    @model = model_class.includes(model_includes)
    authorize @model

    @new_model = model_class.new
  end

  def show
    authorize @model
  end

  def create(redirect_uri = nil) # rubocop:disable Metrics/AbcSize
    @model = model_class.new(permitted_attributes)
    authorize @model

    if @model.save
      flash[:success] = "Successfully created #{model_class.to_s.underscore}"
    else
      flash[:error] = @model.errors.full_messages.join(', ')
    end

    redirect_to redirect_uri || request.referer
  end

  def update(redirect_uri = nil)
    authorize @model

    if @model.update(permitted_attributes)
      flash[:success] = "Successfully updated #{model_class.to_s.underscore}"
    else
      flash[:error] = @model.errors.full_messages.join(', ')
    end

    redirect_to redirect_uri || request.referer
  end

  def new_session_path(_scope)
    root_path
  end

  private

  def user_not_authorized
    head :forbidden
  end

  def set_model
    @model = model_class.includes(model_includes).find(params[:id])
  end

  def model_class
    self.class.name.underscore.sub('v1/', '').sub(/_controller$/, '')
        .singularize.to_s.camelize.safe_constantize
  end

  def records
    @objects ||= model_class.all
  end

  def model_includes
    []
  end

  def model_params
    []
  end

  def permitted_attributes
    params.require(model_class.to_s.underscore.to_sym).permit(model_params)
  end
end
