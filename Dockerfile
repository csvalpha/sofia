FROM ruby:3.3.7-alpine@sha256:6b6a2db6b52015669dcc4b3613c1cfd02f7a74ebbcad98dbe290a814e8ff84e4

ARG BUILD_HASH='unknown'
ENV BUILD_HASH=$BUILD_HASH
ARG RAILS_ENV='production'
ARG NODE_ENV='production'

# Add build-essential tools.
RUN apk add --update \
  bash \
  build-base \
  git \
  postgresql-dev \
  curl \
  netcat \
  wkhtmltopdf \
  nodejs \
  npm \
  yarn \
  && rm -rf /var/cache/apk/*

# Add Node, required for asset pipeline.
RUN apk add --update nodejs=16.20.2 npm yarn

RUN mkdir /app
WORKDIR /app

# Pre-install gems, so that they can be cached.
COPY Gemfile* /app/
RUN if [ "$RAILS_ENV" = 'production' ] || [ "$RAILS_ENV" = 'staging' ] || [ "$RAILS_ENV" = 'luxproduction' ]; then \
    bundle config set --local without 'development test'; \
  else \
    bundle config set --local without 'development'; \
  fi
RUN bundle install

# Pre-install npm packages, so that they can be cached.
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn
RUN yarn install --immutable

COPY . /app/

# Precompile assets after copying app because whole Rails pipeline is needed.
RUN if [ "$RAILS_ENV" = 'production' ] || [ "$RAILS_ENV" = 'staging' ] || [ "$RAILS_ENV" = 'luxproduction' ]; then \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile; \
  else \
    echo "Skipping assets:precompile"; \
  fi

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
