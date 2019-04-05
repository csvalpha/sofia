STAGE=$BUILDKITE_BRANCH
if [ "$STAGE" = "master" ]; then STAGE='production'; fi
if [ "$STAGE" = "production" ] || [ "$STAGE" = "staging" ]; then echo 'Deploying for stage' $STAGE; else echo 'Stage' $STAGE 'unknown.. skipping deploy'; exit 0; fi

curl -sSf  --request POST \
          -H 'Content-type: application/json' \
          --data '{"username": "Buildkite deploy", "text": "Deploy for tomato '$STAGE' is finished"}' \
          $SLACK_URL
