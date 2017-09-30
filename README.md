Alpha Tomato
============

[![Build Status](https://travis-ci.com/csvalpha/alpha-tomato.svg?token=XFGWKzHpTzj88hKy9q2u&branch=staging)](https://travis-ci.com/csvalpha/alpha-tomato)

Dit is de code die hoor bij het nieuwe streepsysteem, codenaam Alpha Tomato. Er moet nog veel
gebeuren, maar het begin is er.

## Prerequisits

_On Linux-like systems_

- Ruby 2.4.1
- Bundler (`gem install bundler`)
- Postgresql 9.5+

## Installation

1. Clone this repository
1. Run the following commands:
  1. `bundle install` (might take a couple of minutes)
  1. `bundle exec rails db:setup`
  1. `bundle exec rails s`
1. Go to http://localhost:3000 and you should see Alpha Tomato running
