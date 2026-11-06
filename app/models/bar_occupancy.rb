class BarOccupancy
  CACHE_KEY = 'bar_occupancy'.freeze
  EXPIRES_IN = 3.minutes

  def self.enabled?
    Rails.application.config.x.occupancy_api_token.present?
  end

  def self.record(session_active:, count:)
    Rails.cache.write(CACHE_KEY, { session_active:, count: }, expires_in: EXPIRES_IN)
  end

  def self.current
    data = Rails.cache.read(CACHE_KEY)
    return { status: 'unavailable' } if data.nil?
    return { status: 'closed' } unless data[:session_active]

    { status: 'open', count: data[:count] }
  end
end
