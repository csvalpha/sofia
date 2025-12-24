require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Sofia
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.2

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.

    config.time_zone = 'Europe/Amsterdam'

    config.generators.javascript_engine = :js

    config.i18n.default_locale = :nl
    config.i18n.fallbacks = [:nl]

    config.cache_store = :redis_cache_store, {
      url: Rails.application.config_for(:cable)['url'],
      pool_size: ENV.fetch('RAILS_MAX_THREADS', 5).to_i,
      pool_timeout: 5
    }
    config.active_job.queue_adapter = :sidekiq

    config.exceptions_app = routes

    # See https://github.com/kickstarter/rack-attack#getting-started
    config.middleware.use Rack::Attack

    config.x.amber_api_host       = credentials.dig(Rails.env.to_sym, :amber_host)
    config.x.amber_api_url        = "#{Rails.env.development? ? 'http' : 'https'}://#{credentials.dig(Rails.env.to_sym, :amber_host)}"

    config.x.amber_client_id      = credentials.dig(Rails.env.to_sym, :amber_client_id) || ENV.fetch('AMBER_CLIENT_ID', nil)
    config.x.amber_client_secret  = credentials.dig(Rails.env.to_sym, :amber_client_secret) || ENV.fetch('AMBER_CLIENT_SECRET', nil)

    config.x.amber_host           = credentials.dig(Rails.env.to_sym, :amber_host)
    config.x.sofia_host           = credentials.dig(Rails.env.to_sym, :sofia_host)

    config.x.smtp_username        = credentials.dig(:production, :smtp_username)
    config.x.smtp_password        = credentials.dig(:production, :smtp_password)
    config.x.sentry_dsn           = credentials.dig(Rails.env.to_sym, :sentry_dsn)
    config.x.sumup_key            = credentials.dig(Rails.env.to_sym, :sumup_affiliate_key)
    config.x.healthcheck_ids      = credentials.dig(Rails.env.to_sym, :healthcheck_ids)
    config.x.mollie_api_key       = credentials.dig(Rails.env.to_sym, :mollie_api_key)

    config.x.authorize_url        = ENV.fetch('AUTHORIZE_URL', '/oauth/authorize')
    config.x.token_url            = ENV.fetch('TOKEN_URL', '/api/v1/oauth/token')
    config.x.me_url               = ENV.fetch('ME_URL', '/api/v1/users?filter[me]&include="active_groups"')

    config.x.from_email           = ENV.fetch('FROM_EMAIL', 'noreply@example.com')
    config.x.ict_email            = ENV.fetch('ICT_EMAIL', 'ict@example.com')
    config.x.admin_email          = ENV.fetch('ADMIN_EMAIL', 'admin@example.com')
    config.x.treasurer_title      = ENV.fetch('TREASURER_TITLE', 'penningmeester')
    config.x.treasurer_email      = ENV.fetch('TREASURER_EMAIL', 'treasurer@example.com')
    config.x.treasurer_name       = ENV.fetch('TREASURER_NAME', nil)
    config.x.treasurer_phone      = ENV.fetch('TREASURER_PHONE', nil)

    config.x.company_name         = ENV.fetch('COMPANY_NAME', nil)
    config.x.company_iban         = ENV.fetch('COMPANY_IBAN', nil)
    config.x.company_address      = ENV.fetch('COMPANY_ADDRESS', nil)
    config.x.company_website      = ENV.fetch('COMPANY_WEBSITE', nil)
    config.x.company_kvk          = ENV.fetch('COMPANY_KVK', nil)
    config.x.personal_transaction_iban = ENV.fetch('PERSONAL_TRANSACTION_IBAN', nil)

    config.x.site_name            = ENV.fetch('SITE_NAME', 'S.O.F.I.A.')
    config.x.site_short_name      = ENV.fetch('SITE_SHORT_NAME', 'SOFIA')
    config.x.site_long_name       = ENV.fetch('SITE_LONG_NAME', 'Streepsysteem voor de Ordentelijke Festiviteiten van Inleggend Alpha')
    config.x.site_association     = ENV.fetch('SITE_ASSOCIATION', 'C.S.V. Alpha')

    config.x.subprovider_label    = ENV.fetch('SUBPROVIDER_LABEL', nil)
    config.x.deposit_button_enabled = ENV.fetch('DEPOSIT_BUTTON_ENABLED', 'true') == 'true'

    config.x.min_payment_amount   = [ENV.fetch('MIN_PAYMENT_AMOUNT', '21.8').to_f, 0.01].max

    config.x.codes                = {
      beer: ENV.fetch('CODE_BEER', nil),
      low_alcohol_beer: ENV.fetch('CODE_LOW_ALCOHOL_BEER', nil),
      craft_beer: ENV.fetch('CODE_CRAFT_BEER', nil),
      non_alcoholic: ENV.fetch('CODE_NON_ALCOHOLIC', nil),
      distilled: ENV.fetch('CODE_DISTILLED', nil),
      whiskey: ENV.fetch('CODE_WHISKEY', nil),
      wine: ENV.fetch('CODE_WINE', nil),
      food: ENV.fetch('CODE_FOOD', nil),
      tobacco: ENV.fetch('CODE_TOBACCO', nil),
      donation: ENV.fetch('CODE_DONATION', nil),
      credit_mutation: ENV.fetch('CODE_CREDIT_MUTATION', nil),
      cash: ENV.fetch('CODE_CASH', nil),
      pin: ENV.fetch('CODE_PIN', nil)
    }
  end
end
