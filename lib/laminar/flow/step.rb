# frozen_string_literal: true

require 'laminar/flow/options_validator'
require 'active_support'
require 'active_support/core_ext/string/inflections'

module Laminar
  module Flow
    # Specification for an executable step in a Flow.
    class Step
      include OptionsValidator
      attr_reader :name, :branches, :class_name

      VALID_OPTIONS_FOR_STEP = %i[class].freeze

      def initialize(name, options = {})
        validate_options(VALID_OPTIONS_FOR_STEP, options)
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

      # Find the next rule in the flow. Examines the branches associated
      # with the current rule and returns the name of the first branch
      # that satisfies its condition.
      def next_step_name(impl_context)
        branch = @branches.first_applicable(impl_context)
        return if branch.nil?
        branch.name
      end
    end
  end
end
