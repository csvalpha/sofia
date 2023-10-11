FROM ruby:3.2.2-slim@sha256:70370316b02901d7db3f6e453d6259ed4d0d52326d6ac57e3a579f7e3b616e41

# Add build-essential tools.
RUN apt-get update -qq && \
  apt-get install -y \
  build-essential \
  git \
  libpq-dev \
  curl \
  netcat \
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

# Pre-install gems, so that they can be cached.
COPY Gemfile* /app/
RUN if [ "$RAILS_ENV" = 'production' ] || [ "$RAILS_ENV" = 'staging' ]; then \
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
RUN if [ "$RAILS_ENV" = 'test' ] || [ "$RAILS_ENV" = 'production' ] || [ "$RAILS_ENV" = 'staging' ]; then \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rails assets:precompile; \
  else \
    echo "Skipping assets:precompile"; \
  fi

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
