# destroy our test DB before rails gets to open it
begin
  File.delete File.expand_path("../dummy/db/test.sqlite3",  __FILE__)
rescue
  puts "Unable to delete test.sqlite3!\nDon't worry if this is the first time running specs."
end

ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'

Rails.backtrace_cleaner.remove_silencers!

# get some migrations up in here
ActiveRecord::Migrator.migrate File.expand_path("../dummy/db/migrate/", __FILE__)
require File.expand_path("../dummy/db/seeds.rb",  __FILE__)

RSpec.configure do |config|
  require 'rspec/expectations'

  #config.formatter = :documentation
  config.use_transactional_fixtures = true
  config.include RSpec::Matchers
end