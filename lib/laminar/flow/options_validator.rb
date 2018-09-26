# frozen_string_literal: true

module Laminar
  module Flow
    # Concern that adds ability to validate arbitrary directive options.
    module OptionsValidator
      def self.included(base)
        base.class_eval do
          extend ClassMethods
          include InstanceMethods
        end
      end

      # Add class methods and attributes.
      module ClassMethods
        attr_reader :option_list

        # Entry point for defining a flow.
        def valid_options(*args)
          @option_list = args.flatten
        end
      end

      # Add instance methods and attributes
      module InstanceMethods
        def validate_options(options)
          valid = self.class.option_list
          options.each_key do |k|
            unless valid.include?(k)
              raise ArgumentError, "Unknown key: #{k.inspect}. Valid keys are: "\
                "#{valid.map(&:inspect).join(', ')}."
            end
          end
        end
      end
    end
  end
end
