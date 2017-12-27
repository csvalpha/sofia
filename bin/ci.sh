#!/bin/bash
set -e

if [ "${TYPE}" = "lint" ] || [ "${TYPE}" = "" ]; then
  bundle exec rubocop
  bundle exec brakeman -z
  bundle exec slim-lint
  gem install bundler-audit
  bundle-audit update && bundle-audit check
  RAILS_ENV=test bundle exec rails db:create db:environment:set db:schema:load
  bundle exec consistency_fail
  yarn lint
fi

if [ "${TYPE}" = "spec" ] || [ "${TYPE}" = "" ]; then
  RAILS_ENV=test bundle exec rails db:create db:environment:set db:schema:load
  bundle exec rspec
fi
