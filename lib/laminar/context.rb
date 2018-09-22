module Laminar
  class Context < Hash
    def self.build(context = {})
      self === context ? context : new.merge!(context)
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

    def history
      @history
    end

    def record(particle)
      _history << particle
    end

    def _history
      @history ||= []
    end
  end
end
