# Deploy is done via GitHub Actions, see .github directory
# This file is for mina to be able to connect to the rails console on the server

require 'mina/rails'
require 'yaml'
import 'lib/mina/tasks/rails.rake'

set :domain, 'ssh.csvalpha.nl'

# Load deployment targets from config/deploy_targets.yml
deploy_targets_path = File.expand_path('deploy_targets.yml', __dir__)

begin
  deploy_config = YAML.load_file(deploy_targets_path)
rescue Errno::ENOENT => e
  abort "deploy_targets.yml not found at #{deploy_targets_path}: #{e.message}"
rescue Psych::SyntaxError => e
  abort "deploy_targets.yml is malformed: #{e.message}"
end

unless deploy_config.is_a?(Hash) && deploy_config.key?('targets') && deploy_config['targets'].is_a?(Hash)
  abort "deploy_targets.yml must contain a 'targets' mapping with deployment target configurations"
end

deploy_targets = deploy_config['targets']
# Dynamically create mina tasks for each deployment target
deploy_targets.each do |target_name, config|
  task target_name.to_sym do
    set :deploy_to, config['deploy_path']
  end
end
