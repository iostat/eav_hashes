module ActiveRecord
  module EavHashes
    module Util
      # Sanity checks!
      # @param [Hash] options the options hash to check for emptyness and Hashiness
      def self.sanity_check(options)
        raise "options cannot be empty (and you shouldn't be calling this since you left options blank)" if
            (!options.is_a? Hash) or options.empty?
      end

      # Fills in any options not explicitly passed to eav_hash_for and creates an EavEntry type for the table
      # @param [Hash] options the options hash to be filled with defaults on unset keys.
      def self.fill_options_hash(options)
        sanity_check options

        # Generate a unique class name based on the eav_hash's name and owner
        options[:entry_class_name] ||= "#{options[:parent_class_name]}_#{options[:hash_name]}_entry".camelize.to_sym

        # Strip "_entries" from the table name
        if /Entry$/.match options[:entry_class_name]
          options[:table_name] ||= options[:entry_class_name].to_s.tableize.slice(0..-9).to_sym
        else
          options[:table_name] ||= options[:entry_class_name].to_s.tableize.to_sym
        end

        # Create the symbol name for the "belongs_to" association in the entry model
        options[:parent_assoc_name] ||= "#{options[:parent_class_name].to_s.underscore}".to_sym

        # Create the symbol name for the "has_many" association in the parent model
        options[:entry_assoc_name] = options[:entry_class_name].to_s.tableize.to_sym

        # Change slashes to underscores in options to match what's output by the generator
        # TODO: Refactor table naming into one location
        options[:table_name] = options[:table_name].to_s.gsub(/\//,'_').to_sym
        options[:parent_assoc_name] = options[:parent_assoc_name].to_s.gsub(/\//,'_').to_sym
        options[:entry_assoc_name] = options[:entry_assoc_name].to_s.gsub(/\//,'_').to_sym

        # Create our custom type if it doesn't exist already
        options[:entry_class] = create_eav_table_class options

        return options
      end

      # Creates a new type subclassed from ActiveRecord::EavHashes::EavEntry which represents an eav_hash key-value pair
      def self.create_eav_table_class (options)
        sanity_check options

        # Don't overwrite an existing type
        return class_from_string(options[:entry_class_name].to_s) if class_from_string_exists?(options[:entry_class_name])

        # Create our type
        klass = set_constant_from_string options[:entry_class_name].to_s, Class.new(ActiveRecord::EavHashes::EavEntry)

        # Fill in the associations and specify the table it belongs to
        klass.class_eval <<-END_EVAL
          self.table_name = "#{options[:table_name]}"
          belongs_to :#{options[:parent_assoc_name]}
        END_EVAL

        return klass
      end

      # Searches an EavEntry's table for the specified key/value pair and returns an
      # array containing the IDs of the models whose eav_hash key/value pair.
      # You should not run this directly.
      # @param [String, Symbol] key the key to search by
      # @param [Object] value the value to search by. if this is nil, it will return all models which contain `key`
      # @param [Hash] options the options hash which eav_hash_for hash generated.
      def self.run_find_expression (key, value, options)
        sanity_check options
        raise "Can't search for a nil key!" if key.nil?
        if value.nil?
          options[:entry_class].where(
              "entry_key = ? and symbol_key = ?",
              key.to_s,
              key.is_a?(Symbol)
          ).pluck("#{options[:parent_assoc_name]}_id".to_sym)
        else
          val_type = EavEntry.get_value_type value
          if val_type == EavEntry::SUPPORTED_TYPES[:Object]
            raise "Can't search by Objects/Hashes/Arrays!"
          else
            options[:entry_class].where(
                "entry_key = ? and symbol_key = ? and value = ? and value_type = ?",
                key.to_s,
                key.is_a?(Symbol),
                value.to_s,
                val_type
            ).pluck("#{options[:parent_assoc_name]}_id".to_sym)
          end
        end
      end

      # Find a class even if it's contained in one or more modules.
      # See http://stackoverflow.com/questions/3163641/get-a-class-by-name-in-ruby
      def self.class_from_string(str)
        str.split('::').inject(Object) do |mod, class_name|
          mod.const_get(class_name)
        end
      end

      # Check whether a class exists, even if it's contained in one or more modules.
      def self.class_from_string_exists?(str)
        begin
          class_from_string(str)
        rescue
          return false
        end
        true
      end

      # Set a constant from a string, even if the string contains modules. Modules
      # are created if necessary.
      def self.set_constant_from_string(str, val)
        parent = str.deconstantize.split('::').inject(Object) do |mod, class_name|
          mod.const_defined?(class_name) ? mod.const_get(class_name) : mod.const_set(class_name, Module.new())
        end
        parent.const_set(str.demodulize.to_sym, val)
      end
    end
  end
end
