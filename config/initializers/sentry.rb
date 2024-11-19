Sentry.init do |config|
  config.dsn = Rails.application.config.x.sentry_dsn
  config.enabled_environments = %w[production staging luxproduction]
  config.environment = Rails.env
  config.release = ENV.fetch('BUILD_HASH', nil)
end
