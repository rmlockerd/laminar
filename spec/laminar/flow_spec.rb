module Laminar
  RSpec.describe Flow do
    let(:flow) { Class.new.send(:include, Laminar::Flow) }

    describe '#flow' do
      context 'when passed a block containing a flow' do
        let(:flow_block) { Proc.new { flow { step :step1 } } }
        let(:spec) { instance_double('Laminar::Flow::Specification') }

        it 'creates a flow specification' do
          expect(Laminar::Flow::Specification).to receive(:new).once { spec }
          flow.flow(&flow_block)
          expect(flow.flowspec).to eq(spec)
        end
      end
    end

    describe '#call!' do
      it 'invokes the first specified step' do
      end

      it 'raises an error if a step fails' do
      end
    end

    describe '#call' do
      it 'invokes the first specified step' do
      end

      it 'silently stops execution if a step fails' do
      end
    end
  end
end
