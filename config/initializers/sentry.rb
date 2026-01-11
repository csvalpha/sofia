# Load enabled environments from deploy_targets.yml
deploy_targets_path = Rails.root.join('config', 'deploy_targets.yml')
deploy_targets = {}

begin
  raw_config = YAML.load_file(deploy_targets_path)
  if raw_config.is_a?(Hash) && raw_config['targets'].is_a?(Hash)
    deploy_targets = raw_config['targets']
    Rails.logger.warn("Sentry initializer: 'targets' key missing or invalid in #{deploy_targets_path}; defaulting to no enabled environments.")
  end
end

Sentry.init do |config|
  config.dsn = Rails.application.config.x.sentry_dsn
  config.enabled_environments = deploy_targets.values.map { |target| target['stage'] }.compact.uniq.map(&:to_sym)
  config.environment = Rails.env
  config.release = ENV.fetch('BUILD_HASH', nil)
end
