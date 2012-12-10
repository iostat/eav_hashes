require 'rails/generators'
require 'rails/generators/active_record'

class EavMigrationGenerator < ActiveRecord::Generators::Base

  source_root File.expand_path "../templates", __FILE__
  # small hack to override NamedBase displaying NAME
  argument :name, :required => true, :type => :string, :banner => "<ModelName>"
  argument :hash_name, :required => true, :type => :string, :banner => "<hash_name>"
  argument :custom_table_name, :required => false, :type => :string, :banner => "table_name"

  def create_eav_migration
    p name
    migration_template "eav_migration.erb", "db/migrate/#{migration_file_name}.rb"
  end

  def migration_file_name
    "create_#{name}_#{hash_name}".underscore
  end

  def migration_name
    migration_file_name.camelize
  end

  def table_name
    custom_table_name || "#{name}_#{hash_name}".underscore
  end

  def model_name
   name
  end
end