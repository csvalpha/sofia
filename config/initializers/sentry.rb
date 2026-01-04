# Load enabled environments from deploy_targets.yml
deploy_targets = YAML.load_file(Rails.root.join('config', 'deploy_targets.yml'))['targets']

Sentry.init do |config|
  config.dsn = Rails.application.config.x.sentry_dsn
  config.enabled_environments = deploy_targets.keys
  config.environment = Rails.env
  config.release = ENV.fetch('BUILD_HASH', nil)
end
