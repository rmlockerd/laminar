require 'support/flow_spec_helpers'

RSpec.describe 'Scenario' do
  context 'when flows are nested' do
  end

  context 'when a step fails' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::WithNoArgs'
          step :step2, class: 'MockParticle::Fails'
          step :step3, class: 'MockParticle::WithNoArgs'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'marks the context as halted' do
      expect(result.halted?).to be true
    end

    it 'marks the context as failed' do
      expect(result.failed?).to be true
    end
  end

  context 'when a before cb soft halts' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::BeforeSoftHalts'
          step :step2, class: 'MockParticle::ShouldSkip'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'does not run step' do
      expect(result[:particle_not_skipped]).to be_falsey
    end

    it 'does not run particle after callbacks' do
      expect(result[:after_cb_not_skipped]).to be_falsey
    end

    it 'halts the flow' do
      expect(result.halted?).to be true
    end

    it 'marks the context as successful' do
      expect(result.failed?).to be false
    end

    it 'merges context' do
      expect(result[:message]).to match(/soft halted/)
    end
  end

  context 'when a step soft halts' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::SoftHalts'
          step :step2, class: 'MockParticle::ShouldSkip'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'skips remaining steps' do
      expect(result).to_not include(no_skip: true)
    end

    it 'halts the flow' do
      expect(result.halted?).to be true
    end

    it 'marks the context as successful' do
      expect(result.failed?).to be false
    end

    it 'merges context' do
      expect(result[:message]).to match(/soft halted/)
    end

    it 'does not run particle after callbacks' do
      expect(result[:after_cb_not_skipped]).to be_falsey
    end
  end

  context 'when a step halts' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::WithNoArgs'
          step :step2, class: 'MockParticle::Halts'
          step :step3, class: 'MockParticle::ShouldSkip'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'skips remaining steps' do
      expect(result).to_not include(no_skip: true)
    end

    it 'halts the flow' do
      expect(result.halted?).to be true
    end

    it 'marks the context as successful' do
      expect(result.failed?).to be false
    end
  end

  context 'when a step uses endflow keyword' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::WithNoArgs' do
            endflow
          end
          step :step2, class: 'MockParticle::ShouldSkip'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'skips remaining steps' do
      expect(result).to_not include(no_skip: true)
    end

    it 'does not mark halted' do
      expect(result.halted?).to be false
    end

    it 'marks the context as successful' do
      expect(result.failed?).to be false
    end
  end

  context 'when a step branches to endflow' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::WithNoArgs' do
            branch :endflow
          end
          step :step2, class: 'MockParticle::ShouldSkip'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'skips remaining steps' do
      expect(result).to_not include(no_skip: true)
    end

    it 'does not mark halted' do
      expect(result.halted?).to be false
    end

    it 'marks the context as successful' do
      expect(result.failed?).to be false
    end
  end

  context 'when a flow executes the final step' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::WithNoArgs'
          step :step2, class: 'MockParticle::WithNoArgs'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'does not mark halted' do
      expect(result.halted?).to be false
    end

    it 'marks the context as successful' do
      expect(result.failed?).to be false
    end
  end

  context 'when final step branches to endflow' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::WithNoArgs' do
            branch :endflow
          end
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'does not mark halted' do
      expect(result.halted?).to be false
    end

    it 'marks the context as successful' do
      expect(result.failed?).to be false
    end
  end

  context 'when a step has no branches' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::WithNoArgs'
          step :step2, class: 'MockParticle::BranchTarget'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'drops to the next defined step' do
      expect(result).to include(target: true)
    end
  end

  context 'when no branch condition is met' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::WithNoArgs' do
            branch :step3, if: :false_condition
          end
          step :step2, class: 'MockParticle::BranchTarget'
          step :step3, class: 'MockParticle::WithNoArgs'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'drops to the next defined step' do
      result = flow.call(flatulent: :cow)
      expect(result).to include(target: true)
    end
  end

  context 'when one branch condition is met' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::WithNoArgs' do
            branch :step3, if: :true_condition
          end
          step :step2, class: 'MockParticle::ShouldSkip'
          step :step3, class: 'MockParticle::BranchTarget'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'drops to the next defined step' do
      result = flow.call(flatulent: :cow)
      expect(result).to_not include(no_skip: true)
      expect(result).to include(target: true)
    end
  end

  context 'when multiple branch conditions could satisfy' do
    let(:flow) {
      flow_factory do
        flow do
          step :step1, class: 'MockParticle::WithNoArgs' do
            branch :step4, if: :true_condition
            branch :step3, if: :true_condition
          end
          step :step2, class: 'MockParticle::ShouldSkip'
          step :step3, class: 'MockParticle::ShouldSkip'
          step :step4, class: 'MockParticle::BranchTarget'
        end
      end
    }
    let(:result) { flow.call(flatulent: :cow) }

    it 'follows the first qualifying branch' do
      result = flow.call(flatulent: :cow)
      expect(result).to_not include(no_skip: true)
      expect(result).to include(target: true)
    end
  end
end
