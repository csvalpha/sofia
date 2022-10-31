# Deploy is done via GitHub Actions, see .github directory
# This file is for mina to be able to connect to the rails console on the server

require 'mina/rails'
import 'lib/mina/tasks/rails.rake'

set :domain, 'ssh.csvalpha.nl'

task :staging do
  set :deploy_to, '/opt/docker/sofia/staging'
end

task :production do
  set :deploy_to, '/opt/docker/sofia/production'
end
