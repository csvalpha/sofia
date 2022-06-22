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

    config.x.banana_client_id     = credentials.dig(Rails.env.to_sym, :banana_client_id) || ENV.fetch('BANANA_CLIENT_ID', nil)
    config.x.banana_client_secret = credentials.dig(
      Rails.env.to_sym, :banana_client_secret
    ) || ENV.fetch('BANANA_CLIENT_SECRET', nil)

    config.x.banana_host          = credentials.dig(Rails.env.to_sym, :banana_host)
    config.x.tomato_host          = credentials.dig(Rails.env.to_sym, :tomato_host)

    config.x.slack_webhook        = credentials.dig(Rails.env.to_sym, :slack_webhook) || ''
    config.x.slack_channel        = '#monitoring'

    config.x.smtp_username        = credentials.dig(:production, :smtp_username)
    config.x.smtp_password        = credentials.dig(:production, :smtp_password)
    config.x.sentry_dsn           = credentials.dig(Rails.env.to_sym, :sentry_dsn)
    config.x.sumup_key            = credentials.dig(Rails.env.to_sym, :sumup_affiliate_key)
    config.x.healthcheck_ids      = credentials.dig(Rails.env.to_sym, :healthcheck_ids)
    config.x.mollie_api_key       = credentials.dig(Rails.env.to_sym, :mollie_api_key)

    config.x.from_email           = ENV.fetch('FROM_EMAIL', 'noreply@example.com')
    config.x.ict_email            = ENV.fetch('ICT_EMAIL', 'ict@example.com')
    config.x.admin_email          = ENV.fetch('ADMIN_EMAIL', 'admin@example.com')
    config.x.treasurer_email      = ENV.fetch('TREASURER_EMAIL', 'treasurer@example.com')
    config.x.treasurer_name       = ENV.fetch('TREASURER_NAME', nil)
    config.x.treasurer_phone      = ENV.fetch('TREASURER_PHONE', nil)

    config.x.company_name         = ENV.fetch('COMPANY_NAME', nil)
    config.x.company_iban         = ENV.fetch('COMPANY_IBAN', nil)
    config.x.company_address      = ENV.fetch('COMPANY_ADDRESS', nil)
    config.x.company_website      = ENV.fetch('COMPANY_WEBSITE', nil)
    config.x.company_kvk          = ENV.fetch('COMPANY_KVK', nil)
  end
end
