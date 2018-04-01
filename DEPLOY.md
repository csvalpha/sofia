## Deploying
The Capistrano gem is used to deploy Rails to Alpha VPS.

    bundle exec cap production deploy

or for staging

    bundle exec cap staging deploy

We use a continuous development cycle. That means: branch `master` is always in production. When a feature is merged through a PR to `staging`, merge its changes to `master` and deploy as soon as possible. We do not use versioning in any way. In Slack the last deployed version can be looked up.

### Updating Ruby on production
Updating Ruby on production is a bit work, given that you have to install Ruby manually on the server. First, make sure that the master branch you are about to deploy has the new Ruby version in `./.ruby-version`. Before we can actually deploy, we have to prepare our server.

1. `ssh deploy@csvalpha.nl`
2. `~/.rbenv/bin/rbenv install <new>`
3. Update Ruby version in`~/.rbenv/version`
4. Verify used Ruby version `~/.rbenv/bin/rbenv version`
5. Install Bundler for the new Ruby version `~/.rbenv/bin/rbenv exec gem install bundler`
6. Terminate the running SSH session and deploy locally `bundle exec cap production deploy`
7. Verify the web server is successfully started
8. To clean-up, remove the old Ruby version including gems `rm -rf ~/.rbenv/versions/<old>`. Make sure that this Ruby version is not used anywhere else, as for example the automatic back-ups also rely on these Ruby installations.


## Environments
Currently, AMBER is deployed in two environments: Staging and Production. The following applies to both API and UI:

| Environment | URL                 | Purpose                                                         | "Rules" |
| ----------- | ------------------- | --------------------------------------------------------------- | ------- |
| Production  | csvalpha.nl         | The website with production data. Available to members of Alpha | Should always run the latest version of the `master` branch. **Be careful with this environment, it is not a playground!** |
| Staging     | staging.csvalpha.nl | This version runs fake - filler - data, feel free to try out new features on this environment | It is not mandatory that this environment runs the latest version of the `staging` branch. |

> (API) Note on Staging and upgrading the DB: database migrations on Staging are done automatically on `deploy`. However, rollbacks are not. That means that migrating to a newer database `schema.rb` version is OK when trying out new features, but downgrading to an older version should be done manually with `bundle exec rails db:rollback` BEFORE deploying a different version of the API.
