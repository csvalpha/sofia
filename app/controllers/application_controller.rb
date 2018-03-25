class ApplicationController < ActionController::Base
  include Pundit

  before_action :set_raven_context
  before_action :set_paper_trail_whodunnit

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  protect_from_forgery with: :exception

  def new_session_path(_scope)
    root_path
  end

  private

  def user_not_authorized
    head :forbidden
  end

  def records
    @objects ||= model_class.all
  end

  def model_includes
    []
  end

  def set_raven_context
    Raven.user_context(id: current_user&.id)
    Raven.extra_context(params: params.to_unsafe_h, url: request.url)
  end
end
