namespace :db do
  desc "Migrates the database and then loads default data from db/data/*.yml files"
  task :data => ['db:migrate', 'db:data:load']

  namespace :data do
    desc "Load initial database data (in db/data/*.yml) into the current environment's database."
    task :load => :environment do
      require 'active_record/fixtures'

      ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
      
      Dir.glob(File.join(RAILS_ROOT, 'db', 'data', '*.yml')).each do |fixture_file|
        Fixtures.create_fixtures(File.dirname(fixture_file), File.basename(fixture_file, '.*'))
      end

    end
  end
end