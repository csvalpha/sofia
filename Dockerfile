FROM ruby:2.5.3-slim
RUN apt-get update -qq \
  && apt-get install -y \
  build-essential \
  git \
  libpq-dev \
  curl
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash - && \
  apt-get install -y \
  nodejs && \
  npm install -g yarn

RUN mkdir /app
WORKDIR /app

# Define args that can be supplied with `docker build --build-args RAILS_ENV=<env>`, defaults to production
ARG RAILS_ENV=production
ARG NODE_ENV=production
ARG RAILS_MASTER_KEY

# Pre-install gems, so that can be cached
COPY Gemfile* /app/
RUN bundle install --without development test

# Pre-install npm packages, so that can be cached
COPY package.json yarn.lock /app/
RUN yarn install

COPY . /app

# Precompile assets after copying app because whole Rails pipeline is needed
RUN bundle exec rails assets:precompile

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
