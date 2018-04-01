# See https://github.com/kickstarter/rack-attack/wiki/Example-Configuration
module Rack
  class Attack
    # Throttle all requests by IP (60rpm)
    #
    # Key: "rack::attack:#{Time.now.to_i/:period}:req/ip:#{req.ip}"
    throttle('req/ip', limit: 300, period: 5.minutes, &:ip)

    self.throttled_response = lambda do |env|
      now = Time.zone.now
      match_data = env['rack.attack.match_data']

      headers = {
        'X-RateLimit-Limit' => match_data[:limit].to_s,
        'X-RateLimit-Remaining' => '0',
        'X-RateLimit-Reset' => (now + (match_data[:period] - now.to_i % match_data[:period])).to_s,
        'Content-Type' => 'application/json; charset=utf-8'
      }

      [429, headers, [{ errors: {} }.to_json]]
    end
  end
end
