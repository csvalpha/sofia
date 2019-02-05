namespace :sentry do
  task :notify_deployment do
    comment "Notifying Sentry of release... #{fetch(:commit)}"

    url = "#{fetch(:sentry_api_endpoint)}/api/0/projects/"\
           "#{fetch(:sentry_organization)}/#{fetch(:sentry_project)}/releases/"
    command "curl -sS -H 'Content-Type: application/json' \
              -H 'Authorization: Bearer #{fetch(:sentry_api_auth_token)}' \
              --request POST --data '{\"version\": \"#{Time.now.getlocal}\", \
               \"ref\": \"#{fetch(:commit)}\"}' #{url}"
  end
end
