module Laminar
  class Context < Hash
    def success?
      !failed?
    end

    def failed?
      !@failed.nil?
    end

    def fail(context = {})
      @failed = true
      merge!(context)
    end

    def record(particle)
      _history << particle
    end

    def _history
      @history ||= []
    end
  end
end
