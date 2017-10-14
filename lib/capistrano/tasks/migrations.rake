# See https://github.com/capistrano/rails/blob/master/lib/capistrano/tasks/migrations.rake
namespace :docker do
  namespace :deploy do
    namespace :compose do
      task :migrate do
        on roles(fetch(:docker_role)) do
          info '[docker:deploy:compose:migrate] Checking changes in ./db/migrate'
          if test("diff -q #{release_path}/db/migrate #{current_path}/db/migrate")
            info '[docker:deploy:compose:migrate] Skip `docker:deploy:compose:migrate` '\
              '(nothing changed in ./db/migrate)'
          else
            info '[docker:deploy:compose:migrate] Run `docker-compose run web rails db:migrate`'
            invoke :'docker:deploy:compose:migrating'
          end
        end
      end
      task :migrating do
        on roles(fetch(:docker_role)) do
          within release_path do
            execute :"docker-compose", 'run', 'web rails db:migrate'
          end
        end
      end
    end
  end
end
