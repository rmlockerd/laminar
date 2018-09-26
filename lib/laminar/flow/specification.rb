# frozen_string_literal: true

module Laminar
  module Flow
    # Specification for a flow (chained sequence of particles).
    class Specification
      attr_accessor :steps, :first_step

      def initialize(_args = {}, &spec)
        @steps = {}
        instance_eval(&spec) if spec
      end

      def step(name, options = {}, &gotos)
        step = add_step(name, options, &gotos)

        # backport a default next step onto the previous step to point to
        # the current one, unless this is the first step. Allows for simple
        # case where execution just falls through to the next step where they
        # haven't specified any explicit branching or none of the branch
        # conditions get met.
        @prev_step.branch(step.name) unless @prev_step.nil?
        @prev_step = step
      end

      private

      def add_step(name, options = {}, &gotos)
        raise ArgumentError, "Step #{name} defined twice" if @steps.key?(name)
        step = Step.new(name, options, &gotos)
        @first_step ||= step.name
        @steps[step.name] = step
      end
    end
  end
end
