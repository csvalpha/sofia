## Deploying
The Capistrano gem is used to deploy Rails to Alpha VPS.

    bundle exec cap production deploy

or for staging

    bundle exec cap staging deploy

We use a continuous development cycle. That means: branch `master` is always in production. When a feature is merged through a PR to `staging`, merge its changes to `master` and deploy as soon as possible. We do not use versioning in any way. In Slack the last deployed version can be looked up.

## Environments
Currently, AMBER is deployed in two environments: Staging and Production. The following applies to both API and UI:

| Environment | URL                         | Purpose                                                         | "Rules" |
| ----------- | --------------------------- | --------------------------------------------------------------- | ------- |
| Production  | tomato.csvalpha.nl          | The website with production data. Available to members of Alpha | Should always run the latest version of the `master` branch. **Be careful with this environment, it is not a playground!** |
| Staging     | staging.tomato.csvalpha.nl  | This version runs fake - filler - data, feel free to try out new features on this environment | It is not mandatory that this environment runs the latest version of the `staging` branch. |

> (API) Note on Staging and upgrading the DB: database migrations on Staging are done automatically on `deploy`. However, rollbacks are not. That means that migrating to a newer database `schema.rb` version is OK when trying out new features, but downgrading to an older version should be done manually with `bundle exec rails db:rollback` BEFORE deploying a different version of the API.
