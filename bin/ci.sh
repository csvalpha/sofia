#!/bin/bash
set -e

TYPE=$1

if [ "${TYPE}" = "lint" ] || [ "${TYPE}" = "" ]; then
  echo "--- :rubocop: Rubocop"
  bundle exec rubocop

  echo "--- :parcel: Brakeman"
  bundle exec brakeman -z --no-pager

  echo "--- :ruby: Bundle audit"
  gem install bundler-audit
  bundle-audit update && bundle-audit check --ignore CVE-2015-9284 || true
  RAILS_ENV=test bundle exec rails db:create db:environment:set db:schema:load
  # uncomment when it does not fail anymore :)
  # bundle exec database_consistency

  echo "--- :eslint: Yarn lint"
  yarn install # Why do I need to do this again? This was done in Dockerfile, rite?
  yarn lint
  yarn run sass-lint -v -q
fi

if [ "${TYPE}" = "spec" ] || [ "${TYPE}" = "" ]; then
  RAILS_ENV=test bundle exec rails db:create db:environment:set db:schema:load
  RAILS_ENV=test bundle exec rspec
  RAILS_ENV=test bin/rails zeitwerk:check
fi
