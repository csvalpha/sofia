FROM ruby:3.4.10-slim@sha256:9d50d98e61ccbe4f1ef436349911e09b53c42a00364bcd3bda6ac107abc29528

# Define args that can be supplied with
# `docker build --build-args RAILS_ENV=<env>`, defaults to production.
ARG BUILD_HASH='unknown'
ENV BUILD_HASH=$BUILD_HASH
ARG RAILS_ENV='production'
ARG NODE_ENV='production'

# Add build-essential tools.
RUN apt-get update -qq && \
  apt-get install -y \
  build-essential \
  git \
  libpq-dev \
  curl \
  netcat-traditional \
  chromium \
  libyaml-dev \
  fonts-liberation \
  libgbm1 \
  libnss3 \
  libatk-bridge2.0-0 \
  libcups2 \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Add Node, required for asset pipeline.
RUN curl -sL https://deb.nodesource.com/setup_24.x | bash - && \
  apt-get install -y nodejs && \
  npm install -q -g yarn

RUN mkdir /app
WORKDIR /app

# Pre-install gems, so that they can be cached.
COPY Gemfile* /app/
RUN if [ "$RAILS_ENV" != 'development' ] && [ "$RAILS_ENV" != 'test' ]; then \
    bundle config set --local without 'development test'; \
  elif [ "$RAILS_ENV" != 'test' ]; then \
    bundle config set --local without 'development'; \
  fi
RUN bundle install

# Pre-install npm packages, so that they can be cached.
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn .yarn
RUN yarn install --immutable

COPY . /app/

# Precompile assets after copying app because whole Rails pipeline is needed.
RUN if [ "$RAILS_ENV" != 'development' ] && [ "$RAILS_ENV" != 'test' ]; then \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile; \
  else \
    echo "Skipping assets:precompile"; \
  fi

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
