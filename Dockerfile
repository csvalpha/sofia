FROM ruby:3.2.6-slim@sha256:c582e3505878002d0b6e316d14a4543d276c84ba040afc73fceef25b6321f80f

# Add build-essential tools.
RUN apt-get update -qq && \
  apt-get install -y \
  build-essential \
  git \
  libpq-dev \
  curl \
  netcat-traditional \
  wkhtmltopdf

# Add Node, required for asset pipeline.
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get install -y nodejs && \
  npm install -q -g yarn

RUN mkdir /app
WORKDIR /app

# Define args that can be supplied with
# `docker build --build-args RAILS_ENV=<env>`, defaults to production.
ARG BUILD_HASH='unknown'
ENV BUILD_HASH=$BUILD_HASH
ARG RAILS_ENV='production'
ARG NODE_ENV='production'
ARG RAILS_MASTER_KEY

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
RUN --mount=type=secret,id=rails_master_key \
  if [ "$RAILS_ENV" = 'production' ] || [ "$RAILS_ENV" = 'staging' ] || [ "$RAILS_ENV" = 'luxproduction' ]; then \
    # Use secret if RAILS_MASTER_KEY build arg is not set.
    RAILS_MASTER_KEY="${RAILS_MASTER_KEY:-$(cat /run/secrets/rails_master_key)}" bundle exec rails assets:precompile; \
  else \
    echo "Skipping assets:precompile"; \
  fi

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
