ENV["RAILS_ENV"] = "test"
require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'

Rails.backtrace_cleaner.remove_silencers!


# Setup DB
require 'rake'
Dummy::Application.load_tasks

Rake::Task['db:drop'].invoke
Rake::Task['db:create'].invoke
Rake::Task['db:migrate'].invoke
Rake::Task['db:seed'].invoke


# require File.expand_path("../dummy/db/seeds.rb",  __FILE__)

RSpec.configure do |config|
  require 'rspec/expectations'

  #config.formatter = :documentation
  config.use_transactional_fixtures = true
  config.include RSpec::Matchers
end
