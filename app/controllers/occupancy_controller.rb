class OccupancyController < ApplicationController
  # The ESP32 authenticates with a bearer token and has no session to forge
  skip_forgery_protection only: :create

  before_action :authenticate_user!, only: :index
  before_action :authenticate_reader!, only: :create
  after_action :verify_authorized, only: :index

  def index
    authorize :occupancy

    render json: BarOccupancy.current
  end

  def create
    session_active = params[:session_active]
    count = params[:current_occupancy]

    unless [true, false].include?(session_active) && count.is_a?(Integer) && count >= 0
      head :unprocessable_content
      return
    end

    BarOccupancy.record(session_active:, count:)
    head :no_content
  end

  private

  def authenticate_reader!
    token = Rails.application.config.x.occupancy_api_token
    valid = token.present? && authenticate_with_http_token do |given_token, _options|
      ActiveSupport::SecurityUtils.secure_compare(given_token, token)
    end

    head :unauthorized unless valid
  end
end
