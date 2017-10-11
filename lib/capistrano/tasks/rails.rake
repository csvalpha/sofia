namespace :rails do
  desc 'Open the rails console on each of the remote servers'
  task :console do
    on roles(:app), primary: true do
      rails_env = fetch(:stage)
      if rails_env == :production
        execute_interactively '$HOME/.rbenv/bin/rbenv exec bundle exec rails console -e production'
      elsif rails_env == :staging
        execute_interactively 'docker-compose run web bundle exec rails console -e production'
      end
    end
  end

  desc 'Open the rails dbconsole'
  task :dbconsole do
    on roles(:db), primary: true do
      rails_env = fetch(:stage)
      if rails_env == :production
        execute_interactively '$HOME/.rbenv/bin/rbenv exec '\
          'bundle exec rails dbconsole -p -e production'
      elsif rails_env == :staging
        execute_interactively 'docker-compose exec db psql -U postgres'
      end
    end
  end

  def execute_interactively(command)
    user = fetch(:user)
    port = fetch(:port) || 22
    exec "ssh -l #{user} #{host} -p #{port} -t 'cd #{deploy_to}/current && #{command}'"
  end
end
