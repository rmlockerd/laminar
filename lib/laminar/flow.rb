# frozen_string_literal: true

require 'laminar/flow/branch'
require 'laminar/flow/flow_error'
require 'laminar/flow/step'
require 'laminar/flow/specification'

module Laminar
  # Implements a DSL for defining a chain of Particles. Each step (particle)
  # contributes to an overall answer/outcome via a shared context.
  #
  # Simple branching and looping is supported via conditional jumps.
  #
  # The most basic flow is a simple set of steps executed sequentially.
  # @example
  #   flow do
  #     step :first
  #     step :then_me
  #     step :last_step
  #   end
  #
  # Each step symbol names a class that includes Laminar::Particle. The call
  # method specifies keyword arguments that the flow uses to determine which
  # parts of the execution context to pass to the step.
  #
  # By default, the flow uses the step label as the implementation particle
  # name. You can use the class directive to specify an alternate class
  # name. This can be a String or Symbol. Very useful when your particles
  # are organised into modules.
  # @example
  #   flow do
  #     step :first
  #     step :then_me, class: :impl_class
  #     step :third, class: 'MyModule::DoSomething'
  #   end
  #
  # Branching is implemented via the goto directive. These directives are
  # evaluated immediately following the execution of a step.
  #
  # @example
  #   flow do
  #     step :first do
  #       goto :last_step, if: :should_i?
  #     end
  #     step :then_me
  #     step :do_something
  #     step :last_step
  #   end
  #
  # In the previous example, execution will pass to last_step is the supplied
  # method should_i? (on the flow instance) returns true. If no branch
  # satisfies its conditions, execution will fall through to the next step.
  #
  # A step can have
  # muluple goto directives; the flow will take the first branch that
  # it finds that satisfies its specified condition (if any).
  # @example
  #   flow do
  #     step :first do
  #       goto :last_step, if: :should_i?
  #       goto :do_something, unless: :another?
  #     end
  #     step :then_me
  #     step :do_something
  #     step :last_step
  #   end
  #
  # You can use the special goto tag :endflow to conditionally teriminate
  # the flow.
  # @example
  #   flow do
  #     step check_policy do
  #       goto :endflow, if :failed_policy?
  #     end
  #   end
  #
  module Flow
    def self.included(base)
      base.class_eval do
        include Particle

        extend ClassMethods
        include InstanceMethods
      end
    end

    # Add class methods and attributes.
    module ClassMethods
      # @!attribute [r] flowspec
      #  @return [FlowSpec] specification of the class' ruleflow.
      attr_reader :flowspec

      # Entry point for defining a flow.
      def flow(args = {}, &block)
        @flowspec = Specification.new(args, &block)
      end
    end

    # Add instance methods and attributes
    module InstanceMethods
      # @return [FlowSpec] the flow specification for the class.
      def flowspec
        self.class.flowspec
      end

      # Initiates evaluation of the flow.
      # @param object the context/input on which the flow will operate. This
      #   is usually a Hash but in simple cases can be a single object. The
      #   implementing flow class should provide a #context_valid? method
      #   that returns true is the given context contains the minimum required
      #   information.
      def call(*)
        return context if flowspec.nil?

        step = flowspec.steps[flowspec.first_step]
        loop do
          break unless invoke_step(step)

          step = next_step(step)
        end
        context
      end

      private

      def invoke_step(step)
        return if step.nil?

        step.particle.call!(context)
        !context.halted?
      end

      # Given a step, returns the next step that satisfies the
      # execution/branch conditions.
      def next_step(current)
        next_name = current.next_step_name(self)
        return nil unless next_name && next_name != :endflow
        unless flowspec.steps.key?(next_name)
          raise FlowError, "No rule with name or alias of #{next_name}"
        end

        flowspec.steps[next_name]
      end
    end
  end
end
