# Multistage: build and run
FROM ruby:2.5-alpine AS build-stage

# Install build dependencies
RUN apk add --no-cache \
  build-base \
  git \
  libpq \
  curl \
  nodejs \
  yarn

# Create the app folder in advance
RUN mkdir /app
WORKDIR /app

# Define args that can be supplied with `docker build --build-args RAILS_ENV=<env>`, defaults to production
ARG RAILS_ENV=production
ARG NODE_ENV=production

# Pre-install gems, so that can be cached
COPY Gemfile* /app/
RUN bundle install --without development test

# Pre-install npm packages, so that can be cached
COPY package.json yarn.lock /app/
RUN yarn install

# Copy rest of the files
COPY . /app

# Precompile assets after copying app because whole Rails pipeline is needed
RUN bundle exec rails assets:precompile

# Run stage
FROM ruby:2.5-slim as run-stage

COPY --from=build-stage /usr/local/bundle/ /usr/local/bundle/
COPY --from=build-stage /app/ /app/

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
