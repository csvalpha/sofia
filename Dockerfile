FROM ruby:2.4.2-slim
RUN apt-get update -qq \
  && apt-get install -y \
  build-essential \
  git \
  libpq-dev \
  nodejs

RUN mkdir /app
WORKDIR /app

ADD Gemfile /app/Gemfile
ADD Gemfile.lock /app/Gemfile.lock
RUN bundle install --without development test
ADD . /app

CMD bundle exec puma -C config/puma.rb
