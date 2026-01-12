# config/initializers/cache_store.rb

cache_config = if ENV['REDIS_HOST'].present?
                 redis_password = ENV['REDIS_PASSWORD'].present? ? ":#{ENV['REDIS_PASSWORD']}@" : ':'
                 redis_url = "redis://#{redis_password}#{ENV['REDIS_HOST']}:#{ENV.fetch('REDIS_PORT', 6379)}/1"
                 [:redis_cache_store, {
                   url: redis_url,
                   pool: { size: ENV.fetch('RAILS_MAX_THREADS', 5).to_i, timeout: 5 }
                 }]
               else
                 [:memory_store]
               end
Rails.application.config.cache_store(*cache_config)
