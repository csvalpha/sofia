require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Tomato
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.time_zone = 'Europe/Amsterdam'

    config.i18n.default_locale = :nl
    config.i18n.fallbacks = [:nl]

    config.cache_store = :redis_store, "#{Rails.application.config_for(:cable)['url']}/cache",
                         { expires_in: 90.minutes }
    config.active_job.queue_adapter = :sidekiq

    config.exceptions_app = routes

    config.x.banana_api_host  = ENV['BANANA_API_HOST']
    config.x.tomato_host      = ENV['TOMATO_HOST']
    config.x.slack_channel    = '#monitoring'
  end
end
