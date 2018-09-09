set :branch, :master
set :deploy_to, '/opt/projects/alpha-tomato-production'

# disable docker:compose:down for initial deploy
before :"docker:deploy:compose:start", 'docker:compose:down'
after :"docker:deploy:compose:start", 'docker:deploy:compose:migrate'

set :docker_compose, true

set :linked_files, %w[.env]
set :linked_dirs, fetch(:linked_dirs, []).concat(%w[log])
