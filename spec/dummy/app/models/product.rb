class Product < ActiveRecord::Base
  attr_accessible :name
  eav_hash_for :tech_specs
end
