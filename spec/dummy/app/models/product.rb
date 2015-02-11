class Product < ActiveRecord::Base
  eav_hash_for :tech_specs
end
