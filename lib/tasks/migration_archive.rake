# lib/tasks/migration_archive.rake
namespace :db do
  namespace :migrate do
    desc 'Archives old DB migration files'
    task archive: :environment do
      sh 'mkdir -p db/migrate/archive'
      sh 'mv db/migrate/*.rb db/migrate/archive'
    end
  end
end
