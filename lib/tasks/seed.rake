# Shameless copypasta from http://quotedprintable.com/2007/11/16/seed-data-in-rails
namespace :db do
  desc "Load seed fixtures (from db/fixtures) into the current environment's database." 
  task :seed => :environment do
    require 'active_record/fixtures'
    Dir.glob(RAILS_ROOT + '/db/fixtures/initial/*.yml').each do |file|
      Fixtures.create_fixtures('db/fixtures/initial', File.basename(file, '.*'))
    end
  end
  
  task :seed_fixes => :environment do
    require 'active_record/fixtures'
    Dir.glob(RAILS_ROOT + '/db/fixtures/fixes/*.yml').each do |file|
      Fixtures.create_fixtures('db/fixtures/fixes', File.basename(file, '.*'))
    end
  end
end