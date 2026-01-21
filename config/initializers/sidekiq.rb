if ENV['REDIS_HOST'].present?
  redis_password = ENV['REDIS_PASSWORD'].present? ? ":#{ENV['REDIS_PASSWORD']}@" : ':'
  redis_url = "redis://#{redis_password}#{ENV['REDIS_HOST']}:#{ENV.fetch('REDIS_PORT', 6379)}/1"

  Sidekiq.configure_server do |config|
    config.redis = {
      url: redis_url,
      pool_timeout: 5
    }
  end

  Sidekiq.configure_client do |config|
    config.redis = {
      url: redis_url,
      pool_timeout: 5
    }
  end
end
