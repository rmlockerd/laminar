# frozen_string_literal: true

module Laminar
  # The environment and state of a particle (or flow) invocation. The
  # context provides data required for a particle to do its job. A particle can
  # modify the context during execution to return results, errors, etc.
  class Context < Hash
    def self.build(context = {})
      case context
      when self
        context
      else
        new.merge!(context || {})
      end
    end

    def initialize
      @halted = false
      @failed = false
    end

    def success?
      !failed?
    end

    def failed?
      @failed
    end

    def halted?
      @halted
    end

    def halt(context = {})
      @halted = true
      merge!(context)
    end

    def halt!(context = {})
      halt(context)
      raise ParticleStopped, self
    end

    def fail!(context = {})
      @failed = true
      halt!(context)
    end
  end
end
