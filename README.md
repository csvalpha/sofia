Alpha SOFIA
============

[![Continuous Integration](https://github.com/csvalpha/sofia/actions/workflows/continuous-integration.yml/badge.svg)](https://github.com/csvalpha/sofia/actions/workflows/continuous-integration.yml)
[![Continuous Delivery](https://github.com/csvalpha/sofia/actions/workflows/continuous-delivery.yml/badge.svg)](https://github.com/csvalpha/sofia/actions/workflows/continuous-delivery.yml)

The source code belonging to Alpha SOFIA. It is a system built with Ruby on Rails with Turbolinks and a little VueJS, used to manage orders in our own bar "Flux". Users authenticate via OAuth API (currently "Alpha AMBER") to see how much credit they got left, or to be able to register new orders and/or payments.

Use this repository to build upon, use as-is, learn from it, prove a point or whatever 😏

## Prerequisites
If you're going to run the project with Docker, you only need to install the following prerequisites:
* [Docker Engine](https://docs.docker.com/get-docker/) 
* [Docker Compose](https://docs.docker.com/compose/install/)
* Running versions / containers of
  * Alpha AMBER API
  * Alpha AMBER UI (for logging in)

Otherwise, you need the following prerequisites installed:

* Ruby (see `.ruby-version` or use `rvm`)
* Bundler (`gem install bundler`)
* NodeJS (see `.nvmrc`)
* Yarn
* Postgresql 9.5+
* Running versions of
  * Alpha AMBER API
  * Alpha AMBER UI (for logging in)

## Installation

### With Docker
*Note that on Windows `docker compose` in each command needs to be replaced with `docker-compose`*

1. Copy `.env.example` to `.env` with `cp .env.example .env` and edit the values where necessary
1. Build the project using `docker compose -f docker-compose.development.yml build --build-arg RAILS_ENV=development --build-arg NODE_ENV=development`. This will install the dependencies and set up the image. If dependencies are updated/added, you need to run this command again.
1. Create databases and tables and run seeds with `bundle exec rails db:setup` (see tip on how to run commands in the container).



Tip: to run commands in the container, you can run the following:
```
docker compose -f docker-compose.development.yml run sofia <COMMAND>
```
For example:
```
docker compose -f docker-compose.development.yml run sofia bundle exec rspec
```

### Without Docker
1. Copy `.env.example` to `.env` with `cp .env.example .env` and edit the values where necessary
1. Build the project using:
    1. `bundle install` (might take a couple of minutes)
    1. `yarn`
1. Create databases and tables and run seeds with `bundle exec rails db:setup`
1. (When you want to use the invoice module) Follow https://github.com/zakird/wkhtmltopdf_binary_gem#installation-and-usage

### Building updated frontend
Webpacker automatically detects changes and rebuilds any changes made to the frontend of SOFIA when SOFIA is refresed in the browser. If it does not detect your changes, delete the `tmp/cache/webpacker/last-compilation-digest-development` file and refresh SOFIA in your browser to force it to rebuild.

### Credentials

Before you can start the application you will need the `master.key`. Ask a fellow developer for it, or pull it from the server via ssh.

When the `master.key` is present, you can use `bundle exec rails credentials:edit` to open the default editor on your machine to read and edit the credentials. Be informed: these are production credentials so be careful.

[Read more about Rails credentials on EngineYard.com.](https://www.engineyard.com/blog/rails-encrypted-credentials-on-rails-5.2)

#### With Docker
The docker container does not contain any editor so do the following instead:
1. Run `docker compose -f docker-compose.development.yml run sofia sh` to connect to the container
2. In there, run `apt install nano` (or any other editor of your choice, it will deleted again when you close the connection to the container)
3. Then run `EDITOR="nano" bundle exec rails credentials:edit`
4. When done, save the file and close the editor
5. Type `exit` to close the connection to the container

#### Without Docker
Tip: you can also use one of the following commands to use an editor of your choice:

```
$ EDITOR="atom --wait" bundle exec rails credentials:edit
$ EDITOR="subl --wait" bundle exec rails credentials:edit
$ EDITOR="code --wait" bundle exec rails credentials:edit
```

### OAuth configuration
To be able to login into SOFIA it needs to be registered as an application in AMBER API.

In the AMBER API ([github.com/csvalpha/amber-api](https://github.com/csvalpha/amber-api)), execute the following command (in `rails console`):

```ruby
app = Doorkeeper::Application.create(name: 'SOFIA - Streepsysteem der C.S.V. Alpha', redirect_uri: 'http://localhost:5000/users/auth/amber_oauth2/callback', scopes: 'public tomato')
app.uid
app.plaintext_secret
```

Next, copy the uid and plaintext secret to the `.env` in SOFIA (as `AMBER_CLIENT_ID` and `AMBER_CLIENT_SECRET` respectively).

### Configuring roles

Users can have roles in SOFIA, namely Treasurer ("SB-penningmeester") and/or Main Bartender ("Hoofdtapper"). A user can also log in without a role. These roles are derived from the groups the user is in. These groups are saved in the AMBER API.

Roles are created in the following way during the seeding:

```ruby
Role.create(role_type: :treasurer, group_uid: 3)
Role.create(role_type: :main_bartender, group_uid: 3)
Role.create(role_type: :main_bartender, group_uid: 2)
```

Tip:
users with the `treasurer` role can see all pages on SOFIA. Since this one is linked to `group_uid: 3` in the development and staging versions of SOFIA, which corresponds to the group *Bestuur* on amber-ui, you can add yourself to that group on amber-ui to see all pages on SOFIA. In production the roles are linked to different groups and you would have to ask the actual treasurer for permission as the production version contains sensitive data.

## Usage
If you're using Docker, you can run the project by using `docker compose -f docker-compose.development.yml up`, otherwise run `bundle exec rails server -p 5000` (port specified so it doesn't use the same as AMBER API).

Go to http://localhost:5000 and you should see SOFIA running

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
