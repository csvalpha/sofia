class ApplicationController < ActionController::Base
  include Pundit::Authorization

  protect_from_forgery with: :exception, prepend: true

  before_action :set_sentry_context
  before_action :set_paper_trail_whodunnit
  before_action :set_layout_flag

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

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

  def set_sentry_context
    Sentry.set_user(id: current_user&.id)
    Sentry.set_extras(params: params.to_unsafe_h, url: request.url)
  end

  def set_layout_flag
    @show_navigationbar = true
    @show_extras = true
  end

  def normalize_error_messages(full_messages)
    full_messages.map(&:downcase).join(', ')
  end
end
