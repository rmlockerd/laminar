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
end
