Alpha SOFIA
============

![Build Status](https://badge.buildkite.com/78b9e8a74bf2160a0d4cb7b72a17ee7d4a1590b3b3eaf847db.svg?branch=staging)
[![Depfu](https://badges.depfu.com/badges/511b8df2e034f68fa0e7b3a4ac476094/overview.svg)](https://depfu.com/github/csvalpha/sofia?project_id=7740)

The source code belonging to Alpha SOFIA. It is a system built with Ruby on Rails with Turbolinks and a little VueJS, used to manage orders in our own bar "Flux". Users authenticate via OAuth API (currently "Alpha Banana") to see how much credit they got left, or to be able to register new orders and/or payments.

Use this repository to build upon, use as-is, learn from it, prove a point or whatever 😏

## Prerequisits

_On Linux-like systems_

- Ruby (see `.ruby-version`)
- Bundler (`gem install bundler`)
- NodeJS (see `.nvmrc`)
- Yarn
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
1. Go to http://localhost:5000 and you should see SOFIA running
1. Copy `.env.example` to `.env` with `cp .env.example .env` and edit the values where necessary

### Credentials

Before you can start the application you will need the `master.key`. Ask a fellow developer for it, or pull it from the server via ssh.

When the `master.key` is present, you can use `bundle exec rails credentials:edit` to open the default editor on your machine to read and edit the credentials. Be informed: these are production credentials so be careful.

[Read more about Rails credentials on EngineYard.com.](https://www.engineyard.com/blog/rails-encrypted-credentials-on-rails-5.2)

Tip: you can also use one of the following commands to use an editor of your choice:

```
$ EDITOR="atom --wait" bundle exec rails credentials:edit
$ EDITOR="subl --wait" bundle exec rails credentials:edit
$ EDITOR="code --wait" bundle exec rails credentials:edit
```

### OAuth configuration

In OAuth Banana (github.com/csvalpha/alpha-banana-api), execute the following command (in `rails console`):

```ruby
Doorkeeper::Application.create(name: 'SOFIA - Streepsysteem der C.S.V. Alpha', redirect_uri: 'http://localhost:5000/users/auth/banana_oauth2/callback', scopes: 'tomato')
```

Next, copy the uid and secret to the `.env` in SOFIA (as `banana_client_id` and `banana_client_secret`).

### Configuring roles

Users can have roles in SOFIA, namely Treasurer ("SB-penningmeester") and/or Main Bartender ("Hoofdtapper"). A user can also log in without a role. These roles are derived from the groups the user is in. These groups are saved in the Banana API.

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
