class ErrorsController < ApplicationController
  layout "application"

  def forbidden
    render template: 'errors/forbidden', status: :forbidden
  end

  def not_found
    render template: 'errors/not_found', status: :not_found
  end

  def unacceptable
    render template: 'errors/unacceptable', status: :unprocessable_entity
  end

  def internal_server_error
    render template: 'errors/internal_server_error', status: :internal_server_error
  end
end