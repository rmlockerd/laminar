require 'support/flow_spec_helpers'

# Tests for
RSpec.describe 'RequiredContext' do
  context 'when required parameter missing' do
    let(:flow) {
      flow_factory do
        flow do
          context_must_have :param1

          step :step1, class: 'MockParticle::ShouldSkip'
        end
      end
    }

    it 'raises an error' do
      expect { flow.call!(flatulent: :cow) }.to raise_error(ArgumentError, /param1/)
    end
  end

  context 'when missing multiple required parameters' do
    let(:flow) {
      flow_factory do
        flow do
          context_must_have :param1, :param2, 'param3'

          step :step1, class: 'MockParticle::ShouldSkip'
        end
      end
    }

    it 'raises an error' do
      expect {
        flow.call!(param2: 'here')
      }.to raise_error(ArgumentError, /param1, param3/)
    end
  end

  context 'when called multiple times' do
    let(:flow) {
      flow_factory do
        flow do
          context_must_have :param1, :param2
          context_must_have :param3, :param4

          step :step1, class: 'MockParticle::ShouldSkip'
        end
      end
    }

    it 'requires all' do
      expect {
        flow.call!(param1: true, param4: true)
      }.to raise_error(ArgumentError, /param2, param3/)
    end
  end
end
