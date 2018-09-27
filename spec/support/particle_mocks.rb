module MockParticle
  class WithNoArgs
    include Laminar::Particle

    def call
    end
  end

  class WithKeywordArgs
    include Laminar::Particle

    def call(x:, y:)
    end
  end

  class WithOptionalArgs
    include Laminar::Particle

    def call(x:, y: 2)
    end
  end

  class Halts
    include Laminar::Particle

    def call
      context.halt(message: 'halted')
    end
  end

  class Fails
    include Laminar::Particle

    def call
      context.fail!(message: 'failed')
    end
  end

  class ShouldSkip
    include Laminar::Particle

    def call
      context[:no_skip] = true
    end
  end

  class BranchTarget
    include Laminar::Particle

    def call
      context[:target] = true
    end
  end
end
