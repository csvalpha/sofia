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

COPY Gemfile* /app/
RUN bundle install --without development test
COPY . /app

RUN RAILS_ENV=production bundle exec rails assets:precompile

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
