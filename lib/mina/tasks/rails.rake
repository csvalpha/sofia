namespace :rails do
  desc 'Open the rails console on each of the remote servers'
  task :console do
    set :execution_mode, :exec
    in_path fetch(:deploy_to) do
      command 'docker-compose exec web bundle exec rails console'
    end
  end
end
