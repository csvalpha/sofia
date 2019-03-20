STAGE=$BUILDKITE_BRANCH
if [ "$STAGE" = "master" ]; then STAGE='production'; fi
if [ "$STAGE" = "production" ] || [ "$STAGE" = "staging" ]; then echo 'Deploying for stage' $STAGE; else echo 'Stage' $STAGE 'unknown.. skipping deploy'; exit 0; fi

cd /opt/docker/sofia/$STAGE
docker-compose pull web
docker-compose build web sidekiq
docker-compose run --rm web rails db:migrate
docker-compose up -d web sidekiq
