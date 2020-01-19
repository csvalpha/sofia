require_relative 'boot'

require 'rails/all'

Bundler.require(*Rails.groups)

module Sofia
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.0

    config.time_zone = 'Europe/Amsterdam'

    config.generators.javascript_engine = :js

    config.i18n.default_locale = :nl
    config.i18n.fallbacks = [:nl]

    config.cache_store = :redis_cache_store, { url: Rails.application.config_for(:cable)['url'] }
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
    config.x.sumup_key            = credentials.dig(Rails.env.to_sym, :sumup_affiliate_key)
    config.x.healthcheck_ids      = credentials.dig(Rails.env.to_sym, :healthcheck_ids)
    config.x.mollie_api_key       = credentials.dig(Rails.env.to_sym, :mollie_api_key)
  end
end
