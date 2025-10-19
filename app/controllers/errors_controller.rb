class ErrorsController < ApplicationController
  layout 'errors'

    def forbidden
    render template: 'errors/forbidden', status: :forbidden
  rescue StandardError => e
    Rails.logger.error("Error rendering forbidden page: #{e.message}")
    render plain: "403 Forbidden", status: :forbidden
  end

  def not_found
    render template: 'errors/not_found', status: :not_found
  rescue StandardError => e
    Rails.logger.error("Error rendering not_found page: #{e.message}")
    render plain: "404 Not Found", status: :not_found
  end

  def unacceptable
    render template: 'errors/unacceptable', status: :not_acceptable
  rescue StandardError => e
    Rails.logger.error("Error rendering unacceptable page: #{e.message}")
    render plain: "406 Not Acceptable", status: :not_acceptable
  end

  def internal_server_error
    render template: 'errors/internal_server_error', status: :internal_server_error
  rescue StandardError => e
    Rails.logger.error("Error rendering internal_server_error page: #{e.message}")
    render plain: "500 Internal Server Error", status: :internal_server_error
  end
end
