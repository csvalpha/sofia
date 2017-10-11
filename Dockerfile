FROM ruby:2.4.2-slim
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

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --without development test
ADD . /app

RUN bundle exec rails assets:precompile RAILS_ENV=production

CMD bundle exec puma -C config/puma.rb
