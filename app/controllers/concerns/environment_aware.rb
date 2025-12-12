module EnvironmentAware
  extend ActiveSupport::Concern

  included do
    class_variable_set(:@@deploy_targets, nil)
  end

  def production_deployed?
    self.class.production_deployed?
  end

  class_methods do
    def production_deployed?
      Rails.env.development? || Rails.env.test? ? false : deployed_environments.include?(Rails.env.to_sym)
    end

    def deployed_environments
      load_deploy_targets.keys.map(&:to_sym)
    end

    private

    def load_deploy_targets
      @@deploy_targets ||= begin
        config_path = Rails.root.join('config', 'deploy_targets.yml')
        YAML.load_file(config_path)['targets']
      end
    end
  end
end
