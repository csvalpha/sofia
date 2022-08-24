#!/bin/bash
set -e

TYPE=$1

if [ "${TYPE}" = "lint" ] || [ "${TYPE}" = "" ]; then
  echo "--- :rubocop: Rubocop"
  bundle exec rubocop

  echo "--- :parcel: Brakeman"
  bundle exec brakeman -z --no-pager

  RAILS_ENV=test bundle exec rails db:create db:environment:set db:schema:load
  # Don't check DB consistency until solved: https://github.com/trptcolin/consistency_fail/issues/42
  # bundle exec consistency_fail

  echo "--- :eslint: Yarn lint"
  yarn install # Why do I need to do this again? This was done in Dockerfile, rite?
  yarn lint
  yarn run sass-lint -v -q
fi

if [ "${TYPE}" = "spec" ] || [ "${TYPE}" = "" ]; then
  RAILS_ENV=test bundle exec rails db:create db:environment:set db:schema:load
  RAILS_ENV=test bundle exec rspec
fi
