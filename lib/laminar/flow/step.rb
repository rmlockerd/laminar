# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext/string/inflections'

module Laminar
  module Flow
    # Specification for an executable step in a Flow.
    class Step
      attr_reader :name, :branches, :class_name

      def initialize(name, options = {})
        validate_options(options)
        @class_name = (options[:class] || name).to_s.camelize
        @name = name
        @branches = BranchList.new
      end

      def particle
        class_name.constantize
      end

      def add_branch(target, options = {})
        branches << Branch.new(target, options)
      end

      private

      # Find the next rule in the flow. Examines the branches associated
      # with the current rule and returns the name of the first branch
      # that satisfies its condition.
      def next_step_name(impl_context)
        branch = @branches.first_applicable(impl_context)
        return if branch.nil?
        branch.name
      end

      VALID_OPTIONS_FOR_STEP = %i[class].freeze
      def validate_options(options)
        options.each_key do |k|
          unless VALID_OPTIONS_FOR_STEP.include?(k)
            raise ArgumentError, "Unknown key: #{k.inspect}. Valid keys are: "\
              "#{VALID_OPTIONS_FOR_STEP.map(&:inspect).join(', ')}."
          end
        end
      end
    end
  end
end
