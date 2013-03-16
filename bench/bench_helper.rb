require "benchmark"
require "faker"

class SearchTarget
    def initialize(product)
        @key = product.tech_specs.keys.sample
        @value = product.tech_specs[@key]
    end

    def search
        Product.find_by_tech_specs(@key, @value)
    end

    def to_s
        "#{@key} => #{@value}"
    end
end

def setup(env="bench")
    ENV["RAILS_ENV"] = env
    require File.expand_path("../../spec/dummy/config/environment.rb",  __FILE__)
    ActiveRecord::Migrator.migrate File.expand_path("../../spec/dummy/db/migrate/", __FILE__)
    Rails.backtrace_cleaner.remove_silencers!
end

def generate_fixtures(n)
    fixtures = []
    keys = []

    30.times do
        keys << Faker::Company.name
    end

    n.times do |x|
        p = Product.new
        p.name = Faker::Name.name

        keys.sample(rand(15) + 5).each do |key|
            p.tech_specs[key] = [Faker::Company.bs, [rand(), rand(500000)].sample].sample
        end

        fixtures << p

        print "\rGenerated #{x} fixtures."
    end
    puts

    fixtures
end

def save_fixtures(fixtures)
    cnt = 0
    ActiveRecord::Base.transaction do
        fixtures.each do  |fixture|
            fixture.save!
            cnt += 1
            print "\rsave!'d #{cnt} fixtures."
        end
    end
    puts
end

setup()
fixtures = generate_fixtures(10000)
save_fixtures(fixtures)

needles = fixtures.sample(15).collect { |p| SearchTarget.new(p) }

Benchmark.bmbm do |bm|
    needles.each do |needle|
        bm.report(needle.to_s) { needle.search }
    end
end
