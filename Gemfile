source 'https://rubygems.org'

gem 'bcrypt', '~> 3.1.11'
gem 'bootstrap', '~> 4.0.0.beta3'
gem 'coffee-rails', '~> 4.2'
gem 'devise', '4.4.1'
gem 'devise-i18n', '1.5'
gem 'factory_bot_rails', '~> 4.8.2'
gem 'faker', '~> 1.8.7'
gem 'font-awesome-rails', '~> 4.7'
gem 'jbuilder', '~> 2.7'
gem 'jquery-rails', '~> 4.3.1'
gem 'mailgun_rails', '~> 0.9.0'
gem 'mini_racer', '~> 0.1.14'
gem 'omniauth', '~> 1.7'
gem 'omniauth-oauth2', '~> 1.4'
gem 'paper_trail', '~> 9.0'
gem 'paranoia', '~> 2.2'
gem 'pg', '~> 1.0'
gem 'puma', '~> 3.11'
gem 'pundit', '~> 1.1.0'
gem 'rack-attack', '~> 5.0'
gem 'rails', '~> 5.1.6'
gem 'rails-i18n', '~> 5.1'
gem 'redis-rails', '~> 5.0.2'
gem 'rest-client', '~> 2.0.2'
gem 'sass-rails', '~> 5.0'
gem 'sentry-raven', '~> 2.3'
gem 'sidekiq', '~> 5.1.2'
gem 'sidekiq-scheduler', '~> 2.2.1'
gem 'simple_form', '~> 3.5.0'
gem 'slack-notifier', '~> 2.3.2'
gem 'slim', '~> 3.0.8'
gem 'turbolinks', '~> 5.1'
gem 'uglifier', '~> 4.1'
gem 'validates_timeliness', '~> 4.0'
gem 'webpacker', '~> 3.4'

group :development, :test do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'brakeman', require: false
  gem 'bullet', '~> 5.7'
  gem 'colorize'
  gem 'consistency_fail'
  gem 'dotenv-rails', '~> 2.2.1'
  gem 'guard-livereload', '~> 2.5'
  gem 'guard-rspec', require: false
  gem 'pry-byebug'
  gem 'pry-rails'
  gem 'rspec-rails'
  gem 'slim_lint', '~> 0.14'
end

group :development do
  gem 'capistrano-sidekiq'
  gem 'foreman', require: false
  gem 'listen'
  gem 'spring', require: false
  gem 'spring-commands-rspec', require: false
  gem 'spring-watcher-listen', require: false
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'rubocop', '~> 0.52', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'terminal-notifier-guard'
end

group :deploy do
  gem 'capistrano', '= 3.10.1' # keep version in sync with version locked in ./config/deploy.rb
  gem 'capistrano-docker', git: 'https://github.com/netguru/capistrano-docker.git', tag: 'v0.2.11'
  gem 'slackistrano', '~> 3.8.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
