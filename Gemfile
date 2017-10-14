source 'https://rubygems.org'

gem 'bcrypt', '~> 3.1.7'
gem 'best_in_place', '~> 3.1.1'
gem 'bootstrap', '~> 4.0.0.beta'
gem 'bootstrap_autocomplete_input'
gem 'coffee-rails', '~> 4.2'
gem 'factory_girl_rails', '~> 4.8'
gem 'faker', '~> 1.7'
gem 'jbuilder', '~> 2.5'
gem 'jquery-rails', '~> 4.3.1'
gem 'mini_racer', '~> 0.1.14'
gem 'paranoia', '~> 2.2'
gem 'pg', '~> 0.21.0'
gem 'puma', '~> 3.7'
gem 'rails', '~> 5.1.2'
gem 'sass-rails', '~> 5.0'
gem 'sentry-raven', '~> 2.3'
gem 'simple_form', '~> 3.5.0'
gem 'slim', '~> 3.0.8'
gem 'turbolinks', '~> 5'
gem 'uglifier', '>= 1.3.0'
gem 'validates_timeliness', '~> 4.0'
gem 'webpacker', '~> 3.0.2'

group :development, :test do
  gem 'awesome_print'
  gem 'better_errors'
  gem 'brakeman', require: false
  gem 'bullet'
  gem 'colorize'
  gem 'consistency_fail'
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
  gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'spring-watcher-listen'
  gem 'web-console', '>= 3.3.0'
end

group :test do
  gem 'rubocop', '~> 0.50.0', require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov', require: false
  gem 'terminal-notifier-guard'
end

group :deploy do
  gem 'capistrano', '= 3.9.1' # keep version in sync with version locked in ./config/deploy.rb
  gem 'capistrano-docker', git: 'https://github.com/netguru/capistrano-docker.git', tag: 'v0.2.11'
  gem 'slackistrano', '~> 3.8.1'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]
