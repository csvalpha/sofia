# Deploy is done via GitHub Actions, see .github directory
# This file is for mina to be able to connect to the rails console on the server

require 'mina/rails'
require 'yaml'
import 'lib/mina/tasks/rails.rake'

set :domain, 'ssh.csvalpha.nl'

# Load deployment targets from config/deploy_targets.yml
deploy_targets_path = File.expand_path('deploy_targets.yml', __dir__)

begin
  deploy_config = YAML.safe_load_file(deploy_targets_path, permitted_classes: [], permitted_symbols: [], aliases: false)

deploy_targets = deploy_config['targets']
# Dynamically create mina tasks for each deployment target
deploy_targets.each do |target_name, config|
  task target_name.to_sym do
    set :deploy_to, config['deploy_path']
  end
end
