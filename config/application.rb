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

    # See https://github.com/kickstarter/rack-attack#getting-started
    config.middleware.use Rack::Attack

    config.x.banana_api_host      = credentials.dig(Rails.env.to_sym, :banana_host)
    config.x.banana_api_url       = "#{Rails.env.development? ? 'http' : 'https'}://#{credentials.dig(Rails.env.to_sym, :banana_host)}"

    config.x.banana_client_id     = credentials.dig(Rails.env.to_sym, :banana_client_id) || ENV['BANANA_CLIENT_ID']
    config.x.banana_client_secret = credentials.dig(
      Rails.env.to_sym, :banana_client_secret
    ) || ENV['BANANA_CLIENT_SECRET']

    config.x.banana_host          = credentials.dig(Rails.env.to_sym, :banana_host)
    config.x.tomato_host          = credentials.dig(Rails.env.to_sym, :tomato_host)

    config.x.slack_webhook        = credentials.dig(Rails.env.to_sym, :slack_webhook) || ''
    config.x.slack_channel        = '#monitoring'

    config.x.mailgun_api_key      = credentials.dig(Rails.env.to_sym, :mailgun_api_key)
    config.x.sentry_dsn           = credentials.dig(Rails.env.to_sym, :sentry_dsn)
  end
end
