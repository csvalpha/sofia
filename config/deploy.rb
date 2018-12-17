require 'mina/rails'
require 'mina/git'
import 'lib/mina/tasks/docker.rake'
import 'lib/mina/tasks/rails.rake'
import 'lib/mina/tasks/slack.rake'
import 'lib/mina/tasks/sentry.rake'

set :application_name, 'sofia'
set :domain, 'csvalpha.nl'

# Git config
set :repository, 'git@github.com:csvalpha/alpha-tomato.git'
set :commit, `git rev-parse --short HEAD  | tr -d '\n'`

# Slack config
set :slack_url, 'https://hooks.slack.com/services/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'
set :slack_room, '#monitoring'
set :slack_stage, fetch(:stage)

# Docker config
set :docker_registry, 'docker.csvalpha.nl/'
set :docker_registry_user, 'csvalpha'
set :docker_registry_password, ENV['DOCKER_PASSWORD']
set :docker_image, 'sofia'

# Sentry config
set :sentry_api_endpoint, 'https://sentry.io'
set :sentry_api_auth_token, 'a149a77cd6254b558b719ca578002675b0fd7e1771e34a24b2e5d2667aa92fcd'
set :sentry_organization, 'csvalpha'

task :staging do
  set :stage, 'staging'
  set :deploy_to, '/opt/docker/tomato/staging'
  set :branch, 'staging'
  set :docker_tag, 'staging'
  set :branch, 'staging'
  set :sentry_project, 'alpha-tomato-staging'
end

task :production do
  set :stage, 'production'
  set :deploy_to, '/opt/docker/tomato/production'
  set :branch, 'master'
  set :docker_tag, 'latest'
  set :branch, 'master'
  set :sentry_project, 'alpha-tomato-production'
end

desc 'Deploys the current version to the server.'
task :deploy do
  set :task_name, 'deploy'

  invoke 'slack:starting'

  invoke 'docker:pull'
  invoke 'docker:migrate_db'
  invoke 'docker:restart'
  invoke 'sentry:notify_deployment'

  invoke 'slack:finished'
end

desc 'Build and publish the image'
task :publish do
  set :task_name, 'publish'

  run(:local) do
    invoke 'slack:starting'

    invoke 'docker:ensure_local_is_clean'
    invoke 'docker:build'
    invoke 'docker:publish'

    invoke 'slack:finished'
  end
end

desc 'Build the image and deploy the current version'
task :full_deploy do
  set :task_name, 'full_deploy'

  run(:local) do
    invoke 'slack:starting'

    invoke 'docker:ensure_local_is_clean'
    invoke 'docker:build'
    invoke 'docker:publish'
  end

  invoke 'deploy'

  invoke 'slack:finished'
end
