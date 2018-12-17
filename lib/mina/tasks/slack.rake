namespace :slack do
  task :starting do
    announcement = "#{fetch(:task_name) || 'unknown action'} is"\
                    " executing for #{fetch(:application_name)} to #{fetch(:stage)}"

    post_slack_message(announcement)
  end

  task :finished do
    announcement = "Successfully deployed #{fetch(:application_name)},"\
                    " stage #{fetch(:stage)}, commit #{fetch(:commit)}"

    post_slack_message(announcement)
  end

  def post_slack_message(message)
    comment 'Sending message to slack'
    command "curl -sS --request POST -H 'Content-type: application/json' \
             --data '{\"channel\": \"#{fetch(:slack_room)}\", \
             \"username\": \"Amber-Api deployer\", \
            \"text\": \"#{message}\"}' #{fetch(:slack_url)}"
  end
end
