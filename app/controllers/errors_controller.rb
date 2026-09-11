class ErrorsController < ApplicationController
  layout 'errors'

  rescue_from StandardError, with: :handle_rendering_error

  def forbidden
    render_error_page('errors/forbidden', :forbidden, '403 Forbidden')
  end

  def not_found
    render_error_page('errors/not_found', :not_found, '404 Not Found')
  end

  def unacceptable
    render_error_page('errors/unacceptable', :not_acceptable, '406 Not Acceptable')
  end

  def unprocessable_entity
    render_error_page('errors/unprocessable_entity', :unprocessable_entity, '422 Unprocessable Entity')
  end

  def internal_server_error
    render_error_page('errors/internal_server_error', :internal_server_error, '500 Internal Server Error')
  end

  private

  def render_error_page(template, status, fallback_message)
    render template: template, status: status
  rescue StandardError => e
    Rails.logger.error("Error rendering #{status} page: #{e.message}")
    render plain: fallback_message, status: status
  end
end
