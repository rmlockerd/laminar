# frozen_string_literal: true

module Laminar
  # Base methods for a logic particle. Particles can be invoked
  # by themselves or as part of a Flow. Classes should include
  # this module rather than inherit.
  module Particle
    def self.included(klass)
      klass.class_eval do
        extend ClassMethods
        include Callbacks
        include InstanceMethods
      end

      attr_reader :context
    end

    # Laminar::Particle class methods and attributes.
    module ClassMethods
      def call(context = {})
        new(context).invoke
      end

      def call!(context = {})
        new(context).invoke!
      end
    end

    module InstanceMethods
      def initialize(context = {})
        @context = Context.build(context)
      end

      def invoke
        invoke!
      rescue ParticleStopped
        context
      end

      def invoke!
        run_before_callbacks
        return context if context.halted?

        param_list = context_slice
        param_list.empty? ? call : call(context_slice)
        run_after_callbacks
        context
      end

      def call; end

      private

      def context_slice
        context.select { |k, _v| introspect_params.include?(k) }
      end

      # Returns an array of keyword parameters that the instance expects
      # or accepts. If the signature includes a 'splat' (:keyrest) to catch
      # a variable set of arguments, returns the current context keys.
      def introspect_params
        params = self.class.instance_method(:call).parameters
        return context.keys if params.map(&:first).include?(:keyrest)

        params.map(&:last)
      end
    end
  end
end
