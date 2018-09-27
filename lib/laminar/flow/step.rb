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

      valid_options %i[class].freeze

      def initialize(name, options = {}, &gotos)
        unless name.class.method_defined?(:to_sym)
          raise ArgumentError, 'invalid name'
        end

        validate_options(options)
        @class_name = (options[:class] || name).to_s.camelize
        @name = name.to_sym
        @branches = []

        instance_eval(&gotos) if gotos
      end

      # Return class instance of the associated particle.
      def particle
        class_name.constantize
      end

      # Add a branch specification to the step.
      def branch(target, options = {})
        branches << Branch.new(target, options)
      end
      alias goto branch

      # Find the next rule in the flow. Examines the branches associated
      # with the current rule and returns the name of the first branch
      # that satisfies its condition.
      def next_step_name(impl_context)
        branch = first_applicable_branch(impl_context)
        return if branch.nil?

        branch.name
      end

      # Return the first branch that satisfies its condition.
      def first_applicable_branch(target)
        branches.each do |branch|
          return branch if branch.meets_condition?(target)
        end
        nil
      end
    end
  end
end
