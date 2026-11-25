# See https://github.com/kickstarter/rack-attack/wiki/Example-Configuration
module Rack
  class Attack
    # Throttle all requests by IP (60rpm)
    # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
    throttle('req/ip', limit: 300, period: 5.minutes, &:ip)

    # The occupancy reader shares a public IP with the bar's order screen, so its pushes must not use up that limit.
    # Requests with a wrong token are still throttled.
    safelist('occupancy reader') do |req|
      token = Rails.application.config.x.occupancy_api_token

      token.present? && req.post? && req.path == '/occupancy' &&
        ActiveSupport::SecurityUtils.secure_compare(req.get_header('HTTP_AUTHORIZATION').to_s, "Bearer #{token}")
    end
  end
end
