#!/bin/bash
set -e

if [ "${TYPE}" = "lint" ] || [ "${TYPE}" = "" ]; then
  bundle exec rubocop
  bundle exec brakeman -z
  bundle exec slim-lint
  gem install bundler-audit
  bundle-audit update && bundle-audit check
  RAILS_ENV=test bundle exec rails db:create db:environment:set db:schema:load
  # Don't check DB consistency until solved: https://github.com/trptcolin/consistency_fail/issues/42
  # bundle exec consistency_fail
  yarn lint
  yarn run sass-lint -v -q
fi

if [ "${TYPE}" = "spec" ] || [ "${TYPE}" = "" ]; then
  RAILS_ENV=test bundle exec rails db:create db:environment:set db:schema:load
  RAILS_ENV=test bundle exec rspec
fi
