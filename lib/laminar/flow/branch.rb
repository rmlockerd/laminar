# frozen_string_literal: true

require 'laminar/flow/options_validator'

module Laminar
  module Flow
    # Specification for a target rule transition.
    class Branch
      include OptionsValidator

      VALID_OPTIONS_FOR_BRANCH = %i[if unless].freeze

      # @!attribute name
      #   @return target rule to branch to
      #
      # @!attribute condition
      #   @return the branch condition (method name symbol or Proc/lambda)
      attr_accessor :name, :condition, :condition_type

      def initialize(name, options = {})
        validate_options(VALID_OPTIONS_FOR_BRANCH, options)
        @name = name.to_sym
        define_condition(options)
      end

      # @param [RuleBase] context a given rule implementation
      #
      # @return [Boolean] true if condition is satisfied in the context.
      def meets_condition?(target)
        return true if condition.nil?
        result = run_condition(target)
        condition_type == :if ? result : !result
      end

      private

      def run_condition(target)
        target.send(@condition)
      end

      def define_condition(options)
        @condition_type = (options.keys & %i[if if_not]).first
        return if @condition_type.nil?
        @condition = options[@condition_type]
        return if @condition.nil? || @condition.is_a?(Symbol)
        raise TypeError, 'condition must be a method (symbol).'
      end
    end
  end
end
