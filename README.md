Alpha Tomato
============

[![Build Status](https://travis-ci.com/csvalpha/alpha-tomato.svg?token=XFGWKzHpTzj88hKy9q2u&branch=staging)](https://travis-ci.com/csvalpha/alpha-tomato)
[![codebeat badge](https://codebeat.co/badges/63a40869-8ae4-4ee9-9575-8899c402f70f)](https://codebeat.co/a/twan-coenraad/projects/github-com-csvalpha-alpha-tomato-master)

Dit is de code die hoor bij het nieuwe streepsysteem, werknaam Alpha Tomato.

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
  1. `bundle exec rails db:setup`
  1. `yarn`
  1. `bundle exec rails s -p 5000` (port specified so it doesn't use the same as Banana API)
1. Go to http://localhost:5000 and you should see Alpha Tomato running
1. Copy `.env.example` to `.env` with `cp .env.example .env` en pas de waarden waar nodig aan

### OAuth configuration

In OAuth Banana (github.com/csvalpha/alpha-banana-api), voer het volgende commando uit:

```ruby
Doorkeeper::Application.create(name: 'Tomato - Streepsysteem der C.S.V. Alpha', redirect_uri: 'http://localhost:5000/users/auth/banana_oauth2/callback')
```

Vervolgens kopieer je de uid en secret naar de `.env` in Tomato (als `banana_client_id` en `banana_client_secret`).

### Configuring roles

Gebruikers kunnen in Tomato rollen hebben, namelijk "SB-penningmeester" en/of "Hoofdtapper". Een gebruiker kan ook inloggen zonder rol. Deze rollen worden afgeleid van de groepen waar een gebruiker in zit, die groepen zijn opgeslagen in de Banana API.

```ruby
Role.create(name: 'Treasurer', group_uid: <SB Treasurer Group UID>)
Role.create(name: 'Main Bartender', group_uid: <Main Bartenders Group UID>)

```
