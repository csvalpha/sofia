FROM ruby:3.0.2-slim

# Add build-essential tools
RUN apt-get update -qq \
  && apt-get install -y \
  build-essential \
  git \
  libpq-dev \
  curl \
  netcat \
  wkhtmltopdf

# Add Node, required for asset pipeline
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash - && \
  apt-get install -y nodejs && \
  npm install -q -g yarn

RUN mkdir /app
WORKDIR /app

# Define args that can be supplied with `docker build --build-args RAILS_ENV=<env>`, defaults to production
ARG RAILS_ENV=production
ARG NODE_ENV=production

# Pre-install gems, so that can be cached
COPY Gemfile* /app/
RUN if [ "$RAILS_ENV" = "production" ] || [ "$RAILS_ENV" = "staging" ] ; then bundle config set --local without 'development test'; else bundle config set --local without 'development'; fi
RUN bundle install

# Pre-install npm packages, so that can be cached
COPY package.json yarn.lock /app/
RUN yarn install --frozen-lockfile

COPY . /app/

# Precompile assets after copying app because whole Rails pipeline is needed.
# (pass RAILS_MASTER_KEY to docker build with
# "--secret id=rails_master_key,env=RAILS_MASTER_KEY")
RUN --mount=type=secret,id=rails_master_key \
  if [ "$RAILS_ENV" = 'production' ] || [ "$RAILS_ENV" = 'staging' ]; then \
    RAILS_MASTER_KEY="$(cat /run/secrets/rails_master_key)" \
    bundle exec rails assets:precompile; else echo "Skip assets:precompile" \
  fi

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

