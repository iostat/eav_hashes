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
    end
  end
end
