Alpha Tomato
============

[![Build Status](https://travis-ci.com/csvalpha/alpha-tomato.svg?token=XFGWKzHpTzj88hKy9q2u&branch=staging)](https://travis-ci.com/csvalpha/alpha-tomato)
[![codebeat badge](https://codebeat.co/badges/63a40869-8ae4-4ee9-9575-8899c402f70f)](https://codebeat.co/a/twan-coenraad/projects/github-com-csvalpha-alpha-tomato-master)

Dit is de code die hoor bij het nieuwe streepsysteem, codenaam Alpha Tomato. Er moet nog veel
gebeuren, maar het begin is er.

## Prerequisits

_On Linux-like systems_

- Ruby (see `.ruby-version`)
- Bundler (`gem install bundler`)
- Postgresql 9.5+

## Installation

1. Clone this repository
1. Run the following commands:
  1. `bundle install` (might take a couple of minutes)
  1. `bundle exec rails db:setup`
  1. `bundle exec rails s -p 5000` (port specified so it doesn't use the same as Banana API)
1. Go to http://localhost:5000 and you should see Alpha Tomato running
