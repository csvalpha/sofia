namespace :rails do
  desc 'Open the rails console on each of the remote servers'
  task :console do
    on roles(:app), primary: true do
      execute_interactively 'docker-compose run web bundle exec rails console -e production'
    end
  end

  desc 'Open the rails dbconsole'
  task :dbconsole do
    on roles(:db), primary: true do
      execute_interactively 'docker-compose exec db psql -U postgres'
    end
  end

  def execute_interactively(command)
    user = fetch(:user)
    port = fetch(:port) || 22
    exec "ssh -l #{user} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{command}'"
  end
end
