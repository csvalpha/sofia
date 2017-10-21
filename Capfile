# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# See https://github.com/phallstrom/slackistrano#installation
require 'slackistrano/capistrano'
require_relative 'lib/capistrano/slack'

task :docker do
  require 'capistrano/docker'
  # require 'capistrano/docker/assets'
end

task staging: [:docker]

# Load custom tasks from `lib/capistrano/tasks` if you have any defined
Dir.glob('lib/capistrano/tasks/*.rake').each { |r| import r }
