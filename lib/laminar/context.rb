module Laminar
  # The environment and state of a particle (or flow) invocation. The
  # context provides data required for a particle to do its job. A particle can
  # modify the context during execution to return results, errors, etc.
  class Context < Hash
    def self.build(context = {})
      self == context ? context : new.merge!(context)
    end

    def success?
      !failed?
    end

    def failed?
      !@failed.nil?
    end

    def fail!(context = {})
      @failed = true
      merge!(context)
      raise ParticleFailed, self
    end

    attr_reader :history

    def record(particle)
      _history << particle
    end

    def _history
      @history ||= []
    end
  end
end
