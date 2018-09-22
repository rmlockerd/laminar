module Laminar
  # Base methods for a logic particle. Particles can be invoked
  # by themselves or as part of a Flow. Classes should include
  # this module rather than inherit.
  module Particle
    def self.included(klass)
      klass.extend(ClassMethods)

      attr_reader :context
    end

    # Laminar::Particle class methods and attributes.
    module ClassMethods
      def call(context = {})
        new(context).invoke
      end
    end

    def initialize(context = {})
      @context = context
    end

    def invoke
      call(context_slice)
      @context
    end

    private

    def context_slice
      @context.select { |k, _v| introspect_params.include?(k) }
    end

    # Returns an array of keyword parameters that the instance expects
    # or accepts. If the signature includes a 'splat' (:keyrest) to catch
    # a variable set of arguments, returns the current context keys.
    def introspect_params
      params = self.class.instance_method(:call).parameters
      return @context.keys if params.map(&:first).include?(:keyrest)
      params.map(&:last)
    end
  end
end
