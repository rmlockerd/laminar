# frozen_string_literal: true

module Laminar
  module Flow
    # Concern that adds ability to validate flow directive options.
    module OptionsValidator
      def validate_options(valid, options)
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
