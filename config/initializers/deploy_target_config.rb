# Helper to dynamically generate environment configurations from deploy_targets.yml
module DeployTargetConfig
  def self.load_targets
    @targets ||= YAML.load_file(Rails.root.join('config', 'deploy_targets.yml'))['targets']
  end

  def self.target_stages
    load_targets.keys
  end

  def self.all_production_stages
    target_stages
  end

  def self.production_hostnames
    load_targets.values.map { |config| config['hostname'] }
  end

  def self.staging_hostname
    load_targets['stagingstreep']&.dig('hostname')
  end

  def self.production_deployed?
    production_hostnames.include?(Rails.application.config.x.sofia_host)
  end

  def self.staging_deployed?
    Rails.application.config.x.sofia_host == staging_hostname
  end
end
