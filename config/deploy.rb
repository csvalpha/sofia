# config valid only for current version of Capistrano
lock '3.9.1'

set :application, 'alpha-tomato'
set :repo_url, 'git@github.com:csvalpha/alpha-tomato.git'

set :puma_workers, 2
set :puma_init_active_record, true

set :user, 'deploy'

set :log_level, :info

server 'csvalpha.nl', user: 'deploy', roles: %i[app web db], primary: true

set :sentry_project, "alpha-tomato-#{fetch(:stage)}"
set :sentry_api_endpoint, 'https://sentry.io'
set :sentry_api_auth_token, 'a149a77cd6254b558b719ca578002675b0fd7e1771e34a24b2e5d2667aa92fcd'
set :sentry_organization, 'csvalpha'

after 'deploy:published', 'sentry:notify_deployment'

set :slackistrano,
    klass: Slackistrano::CustomMessaging,
    channel: '#monitoring',
    webhook: 'https://hooks.slack.com/services/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'
