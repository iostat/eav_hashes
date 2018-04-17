$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "eav_hashes/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "eav_hashes"
  s.version     = ActiveRecord::EavHashes::VERSION
  s.authors     = ["Ilya Ostrovskiy"]
  s.email       = [(["ilya","200proof.cc"].join "@")]
  s.homepage    = "https://github.com/200proof/eav_hashes"
  s.summary     = "A developer-friendly implementation of the EAV model for Ruby on Rails."
  s.description = <<-END_DESC
    eav_hashes allows you to to leverage the power of the EAV database model in the way you would expect to use it:
    a hash. Unlike other gems which require you to create a special model and/or define which attributes you want to
    have EAV behavior on (both of which defeat the purpose), all you need to do with eav_hashes is add one line to your
    model and create a migration. All the heavy lifting is done for you.
  END_DESC

  s.files = Dir["lib/**/*"] + %w(init.rb MIT-LICENSE Rakefile README.md)
  s.test_files = Dir["spec/**/*"]

#  s.add_dependency "rails", "~> 3.2.7"
  s.add_dependency "rails", ">= 3.2.7", "< 4"
  s.add_development_dependency "sqlite3"
end
