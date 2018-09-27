# frozen_string_literal: true

module Laminar
  # Raised when someone calls fail!() on a Laminar::Context.
  class ParticleStopped < StandardError
    attr_reader :context

    def initialize(context = nil)
      @context = context
      super
    end
  end
end
