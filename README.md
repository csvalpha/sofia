Alpha SOFIA
============

[![Continuous Integration](https://github.com/csvalpha/sofia/actions/workflows/continuous-integration.yml/badge.svg)](https://github.com/csvalpha/sofia/actions/workflows/continuous-integration.yml)
[![Continuous Delivery](https://github.com/csvalpha/sofia/actions/workflows/continuous-delivery.yml/badge.svg)](https://github.com/csvalpha/sofia/actions/workflows/continuous-delivery.yml)
[![codecov](https://codecov.io/github/csvalpha/sofia/graph/badge.svg?token=RGR5PARLD5)](https://codecov.io/github/csvalpha/sofia)

The source code belonging to Alpha SOFIA. It is a system built with Ruby on Rails with Turbo and a little VueJS, used to manage orders in our own bar "Flux". Users authenticate via OAuth API (currently "Alpha AMBER") or through the builtin login portal to see how much credit they got left, or to be able to register new orders and/or payments.

Use this repository to build upon, use as-is, learn from it, prove a point or whatever 😏

## Prerequisites

_On Linux-like systems_

- Ruby (see `.ruby-version`)
- Bundler (`gem install bundler`)
- NodeJS (see `.nvmrc`)
- Yarn
- Postgresql 14.7+

## Installation

1. Clone this repository
1. Run the following commands:
  1. `bundle install` (might take a couple of minutes)
  1. `yarn install`
  1. `bundle exec rails db:setup`
  1. `bundle exec rails s -b 0.0.0.0 -p 5000`
1. Go to http://localhost:5000 and you should see SOFIA running
1. Copy `.env.example` to `.env` with `cp .env.example .env` and edit the values where necessary
1. (When you want to use the invoice module) Follow https://github.com/zakird/wkhtmltopdf_binary_gem#installation-and-usage

### Credentials

Before you can start the application you will need the `master.key`. Ask a fellow developer for it, or pull it from the server via ssh.

When the `master.key` is present, you can use `bundle exec rails credentials:edit` to open the default editor on your machine to read and edit the credentials. Be informed: these are production credentials so be careful.

[Read more about Rails credentials on EngineYard.com.](https://www.engineyard.com/blog/rails-encrypted-credentials-on-rails-5.2)

```
$ EDITOR=nano bundle exec rails credentials:edit
```

### Configuring roles

Users can have roles in SOFIA, namely Treasurer ("SB-penningmeester"), Renting manager("Verhuur")and/or Main Bartender ("Hoofdtapper"). A user can also log in without a role. These roles are derived from the groups the user is in. These groups are saved in the AMBER API.

Roles are created in the following way during the seeding:

```ruby
Role.create(role_type: :treasurer, group_uid: 4)
Role.create(role_type: :renting_manager, group_uid: 5)
Role.create(role_type: :main_bartender, group_uid: 6)
```

## Testing & Linting

To Run the test locally the following command can be used 
```
bundle exec rspec
```

To run the linting locally you can use the following commands 
```
yarn lint
yarn run sass-lint -v -q
bundle exec rubocop
```
## Migrations 

When migrations are executed on master and everthing worked they can be archived with the following command.

    bundle exec rails db:migrate:archive

## Deploying

Deploying procedure is the same as for the AMBER project.
See [DEPLOY.md](https://github.com/csvalpha/amber-api/blob/master/DEPLOY.md) for that.

## Contributing

When contributing, please consult with the repository owners in advance to ensure a high chance of PR-success. PR-success means you're PR is merged and you'll be mentioned in the contributors list 🎉.

When submitting a PR, it'll need to be approved, but once approved (and green) you're responsible yourself for clicking the merge button and enjoying the intense feeling of satisfaction!

### Contributors

- [@cmitz](https://github.com/cmitz)
- [@Matthijsy](https://github.com/Matthijsy)
- [@cpbscholten](https://github.com/cpbscholten)
- [@wilco375](https://github.com/wilco375)
- [@guidojw](https://github.com/guidojw)
- [@ellen-wittingen](https://github.com/Ellen-Wittingen)
- [@jorai](https://github.com/lodewiges)
