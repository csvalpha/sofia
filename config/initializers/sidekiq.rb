redis_url = Rails.application.config_for(:cable)['url']

if redis_url
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
