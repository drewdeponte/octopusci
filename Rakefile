$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')

task(:environment) do
  require 'octopusci'
end

namespace :db do
  desc "Migrate the database"
  task(:migrate => :environment) do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate(File.expand_path(File.dirname(__FILE__) + "/db/migrate"))
  end
end