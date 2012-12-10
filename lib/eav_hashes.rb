require "eav_hashes/util"
require "eav_hashes/eav_entry"
require "eav_hashes/eav_hash"
require "eav_hashes/activerecord_extension"
require "generators/eav_migration/eav_migration"

# tally-ho!
ActiveRecord::Base.send :include, ActiveRecord::EavHashes
