Raven.configure do |config|
  config.dsn = Rails.application.config.x.sentry_dsn
  config.environments = %w[production staging]
  config.current_environment = Rails.env
  config.release = ENV.fetch('BUILD_HASH', nil)
  config.async = lambda { |event|
    SentryJob.perform_later(event)
  }
  config.sanitize_fields = Rails.application.config.filter_parameters.map(&:to_s)
end
