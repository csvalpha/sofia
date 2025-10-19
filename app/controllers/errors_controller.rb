class ErrorsController < ApplicationController

  def forbidden
    render file: Rails.root.join('public', '403.html'), layout: false, status: :forbidden
  end

  def not_found
    render file: Rails.root.join('public', '404.html'), layout: false, status: :not_found
  end

  def unacceptable
    render file: Rails.root.join('public', '422.html'), layout: false, status: :unprocessable_entity
  end

  def internal_server_error
    render file: Rails.root.join('public', '500.html'), layout: false, status: :internal_server_error
  end
end