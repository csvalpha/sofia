namespace :docker do
  desc 'Build the docker image'
  task :build do
    image = fetch(:docker_image)
    comment "Building docker image #{image}"
    command "docker build -t #{image} ."
  end

  desc 'Publish the docker image'
  task :publish do
    registry = fetch(:docker_registry)
    image = fetch(:docker_image)
    url = "#{registry}#{image}"
    raise ArgumentError, 'DOCKER_PASSWORD environment variable should be set' unless fetch(:docker_registry_password)
    command "docker login #{registry} -u #{fetch(:docker_registry_user)}"\
              " -p #{fetch(:docker_registry_password)}"

    comment "Publishing docker image to #{url}, tags #{fetch(:docker_tag)} and #{fetch(:commit)}"
    command "docker tag #{image} #{url}:#{fetch(:docker_tag)}"
    command "docker tag #{url}:#{fetch(:docker_tag)} #{url}:#{fetch(:commit)}"
    command "docker push #{url}:#{fetch(:docker_tag)}"
    command "docker push #{url}:#{fetch(:commit)}"
  end

  desc 'Ensures that the local working tree is clean'
  task :ensure_local_is_clean do
    comment 'Ensuring local working tree is clean'
    branch = `echo $(git rev-parse --abbrev-ref HEAD) | tr -d "\n"`
    branch = `echo $TRAVIS_BRANCH | tr -d "\n"` if ENV['TRAVIS_BRANCH']
    comment branch
    command %(
        if ! [ #{branch}  = #{fetch(:branch)} ]; then
          echo 'It is only allowed to deploy this stage from branch #{fetch(:branch)}'
          echo 'Current branch is #{branch}'
          exit 1
        fi
        git diff --quiet && git diff --cached --quiet
        if [ $? -ne 0 ]; then
          echo 'Working tree is not clean. Please make sure local version is the same as remote'
          exit 1
        fi
      )
  end

  task :migrate_db do
    in_path fetch(:deploy_to) do
      comment 'Running db migrations'
      command 'docker-compose run web rails db:migrate'
    end
  end

  task :pull do
    raise ArgumentError, 'DOCKER_PASSWORD environment variable should be set' unless fetch(:docker_registry_password)
    in_path fetch(:deploy_to) do
      comment 'Pulling new app version'
      command "docker login #{fetch(:docker_registry)} -u #{fetch(:docker_registry_user)}"\
                " -p #{fetch(:docker_registry_password)}"
      command 'docker-compose pull web sidekiq'
    end
  end

  task :restart do
    in_path fetch(:deploy_to) do
      comment 'Restarting app'
      command 'docker-compose up --build -d web sidekiq'
    end
  end
end
