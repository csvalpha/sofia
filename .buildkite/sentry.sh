STAGE=$BUILDKITE_BRANCH
if [ "$STAGE" = "master" ]; then STAGE='production'; fi
if [ "$STAGE" = "production" ] || [ "$STAGE" = "staging" ]; then echo 'Deploying for stage' $STAGE; else echo 'Stage' $STAGE 'unknown.. skipping deploy'; exit 0; fi

curl -sSf  -H 'Content-Type: application/json' \
          -H 'Authorization: Bearer '$SENTRY_API_TOKEN \
          --request POST \
          --data '{"version": "'"$(date)"'", "ref": "'"$BUILDKITE_COMMIT"'", "environment": "'"$STAGE"'"}' \
          https://sentry.io/api/0/projects/csvalpha/sofia/releases/
