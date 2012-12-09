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
          options[:table_name] ||= options[:entry_class_name].to_s[0..-7].tableize.to_sym
        else
          options[:table_name] ||= options[:entry_class_name].to_s.tableize.to_sym
        end

        # Create the symbol name for the "belongs_to" association in the entry model
        options[:parent_assoc_name] ||= "#{options[:parent_class_name].to_s.underscore}".to_sym

        # Create the symbol name for the "has_many" association in the parent model
        options[:entry_assoc_name] = options[:entry_class_name].to_s.tableize.to_sym

        # Create our custom type if it doesn't exist already
        options[:entry_class] = create_eav_table_class options

        return options
      end

      # Creates a new type subclassed from ActiveRecord::EavHashes::EavEntry which represents an eav_hash key-value pair
      def self.create_eav_table_class (options)
        sanity_check options

        # Don't overwrite an existing type
        return Object.const_get options[:entry_class_name] if Object.const_defined? options[:entry_class_name]

        # Create our type
        klass = Object.const_set options[:entry_class_name], Class.new(ActiveRecord::EavHashes::EavEntry)

        # Fill in the associations and specify the table it belongs to
        klass.class_eval <<-END_EVAL
          belongs_to :#{options[:parent_assoc_name]}
          set_table_name "#{options[:table_name]}"
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
    end
  end
end
