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

def generate_fixture_keys(n=35)
    ret = []
    n.times do
        ret << Faker::Company.name
    end

    ret
end

def generate_fixture(keys)
    p = Product.new
    p.name = Faker::Name.name

    keys.sample(rand(15) + 5).each do |key|
        p.tech_specs[key] = [Faker::Company.bs, [rand(), rand(500000)].sample].sample
    end

    return p
end

# needles = # of search targets
# haystack_size = # of entries for each search target
# 250 needles @ 4000 haystack_size = 1M entries
def create_benchmark(needles, haystack_size)
    ret = []
    keys = generate_fixture_keys()
    cnt = 0

    needles.times do
        curr_haystack = []
        ActiveRecord::Base.transaction do
            haystack_size.times do 
                p = generate_fixture(keys)
                p.save!
                curr_haystack << p
            end
        end
        ret << SearchTarget.new(curr_haystack.sample())

        cnt += 1
        print "\rGenerated #{cnt} needles"
    end

    puts

    ret
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
needles = create_benchmark(250, 4000)

Benchmark.bmbm do |bm|
    needles.each do |needle|
        bm.report(needle.to_s) { needle.search }
    end
end
