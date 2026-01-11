# Load enabled environments from deploy_targets.yml
deploy_targets_path = Rails.root.join('config', 'deploy_targets.yml')
deploy_targets = {}

begin
  raw_config = YAML.load_file(deploy_targets_path)
  if raw_config.is_a?(Hash) && raw_config['targets'].is_a?(Hash)
    deploy_targets = raw_config['targets']
  else
    Rails.logger.warn("Sentry initializer: 'targets' key missing or invalid in #{deploy_targets_path}; defaulting to no enabled environments.")
  end
rescue Errno::ENOENT => e
  Rails.logger.warn("Sentry initializer: deploy targets file not found at #{deploy_targets_path}: #{e.message}; defaulting to no enabled environments.")
rescue Psych::SyntaxError => e
  Rails.logger.error("Sentry initializer: deploy targets file at #{deploy_targets_path} is malformed YAML: #{e.message}; defaulting to no enabled environments.")
rescue StandardError => e
  Rails.logger.error("Sentry initializer: error loading deploy targets from #{deploy_targets_path}: #{e.class}: #{e.message}; defaulting to no enabled environments.")
end
Sentry.init do |config|
  config.dsn = Rails.application.config.x.sentry_dsn
  config.enabled_environments = deploy_targets.values.map { |target| target['stage'] }.compact.uniq.map(&:to_sym)
  config.environment = Rails.env
  config.release = ENV.fetch('BUILD_HASH', nil)
end
