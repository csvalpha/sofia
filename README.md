Alpha Tomato
============

[![Build Status](https://travis-ci.com/csvalpha/alpha-tomato.svg?token=XFGWKzHpTzj88hKy9q2u&branch=staging)](https://travis-ci.com/csvalpha/alpha-tomato)
[![codebeat badge](https://codebeat.co/badges/63a40869-8ae4-4ee9-9575-8899c402f70f)](https://codebeat.co/a/twan-coenraad/projects/github-com-csvalpha-alpha-tomato-master)

The source code belonging to Alpha Tomato (workname). It is a system built with Ruby on Rails with Turbolinks and a little VueJS, used to manage orders in our own bar "Flux". Users authenticate via OAuth API (currently "Alpha Banana") to see how much credit they got left, or to be able to register new orders and/or payments.

Use this repository to build upon, use as-is, learn from it, prove a point or whatever 😏

## Prerequisits

_On Linux-like systems_

- Ruby (see `.ruby-version`)
- Bundler (`gem install bundler`)
- NodeJS (see `.nvmrc`)
- Yarn (preferred, otherwise npm)
- Postgresql 9.5+
- Running versions of
  - Alpha Banana API
  - Alpha Banana UI (for logging in)

## Installation

1. Clone this repository
1. Run the following commands:
  1. `bundle install` (might take a couple of minutes)
  1. `yarn`
  1. `bundle exec rails db:setup`
  1. `bundle exec rails s -p 5000` (port specified so it doesn't use the same as Banana API)
1. Go to http://localhost:5000 and you should see Alpha Tomato running
1. Copy `.env.example` to `.env` with `cp .env.example .env` and edit the values where necessary

### OAuth configuration

In OAuth Banana (github.com/csvalpha/alpha-banana-api), execute the following command:

```ruby
Doorkeeper::Application.create(name: 'Tomato - Streepsysteem der C.S.V. Alpha', redirect_uri: 'http://localhost:5000/users/auth/banana_oauth2/callback', scopes: 'read_user')
```

Next, copy the uid and secret to the `.env` in Tomato (as `banana_client_id` and `banana_client_secret`).

### Configuring roles

Users can have roles in Tomato, namely Treasurer ("SB-penningmeester") and/or Main Bartender ("Hoofdtapper"). A user can also log in without a role. These roles are derived from the groups the user is in. These groups are saved in the Banana API.

Roles are created in the following way during the seeding:

```ruby
Role.create(role_type: :treasurer, group_uid: 3)
Role.create(role_type: :main_bartender, group_uid: 3)
Role.create(role_type: :main_bartender, group_uid: 2)
```

## Deploying
Deploying procedure is the same as for the Banana project.
See [DEPLOY.md](https://github.com/csvalpha/alpha-banana-api/blob/master/DEPLOY.md) for that.


## Contributing

When contributing, please consult with the repository owners in advance to ensure a high chance of PR-success. PR-success means you're PR is merged and you'll be mentioned in the contributors list 🎉.

When submitting a PR, it'll need to be approved, but once approved (and green) you're responsible yourself for clicking the merge button and enjoying the intense feeling of satisfaction!

### Contributors

- [@cmitz](https://github.com/cmitz)
- [@Matthijsy](https://github.com/Matthijsy)
- [@cpbscholten](https://github.com/cpbscholten)
