module Laminar
  RSpec.describe Flow do
    include_examples 'particle_common'

    let(:flow) { Class.new.send(:include, Laminar::Flow) }
    let(:particle) { Class.new.send(:include, Laminar::Particle) }

    describe '#flow' do
      context 'when passed a block containing a flow' do
        let(:spec) { instance_double('Laminar::Flow::Specification') }

        it 'creates a flow specification' do
          expect(Laminar::Flow::Specification).to receive(:new).once { spec }
          flow.flow do
            step :step1
          end
          expect(flow.flowspec).to eq(spec)
        end
      end
    end

    describe '#flowspec' do
      let(:spec) { instance_double('Laminar::Flow::Specification') }

      it 'returns the flow specification' do
        allow(Laminar::Flow::Specification).to receive(:new).and_return(spec)
        flow.flow do
          step :step1
        end
        expect(flow.flowspec).to eq(spec)
      end
    end

    describe '#call' do
      let(:spec) { instance_double('Laminar::Flow::Specification') }
      let(:step) { instance_double('Laminar::Flow::Step', name: :step1) }

      it 'invokes the first step' do
        allow(Laminar::Flow::Specification).to receive(:new).and_return(spec)
        allow(spec).to receive(:steps).and_return({step.name => step})
        allow(spec).to receive(:first_step).and_return(step.name)
        allow(step).to receive(:particle).and_return(particle)
        allow(spec).to receive(:before_step_callbacks).and_return([])
        allow(spec).to receive(:after_step_callbacks).and_return([])
        allow(step).to receive(:next_step_name).and_return(nil)
        expect(particle).to receive(:call!).once

        flow.flow do
          step :step1
        end
        flow.new.call(x: 1, y: 2)
      end

      it 'raises Laminar::ParticleStopped if step fails' do
        allow(Laminar::Flow::Specification).to receive(:new).and_return(spec)
        allow(spec).to receive(:steps).and_return({step.name => step})
        allow(spec).to receive(:first_step).and_return(step.name)
        allow(spec).to receive(:before_step_callbacks).and_return([])
        allow(spec).to receive(:after_step_callbacks).and_return([])
        allow(step).to receive(:particle).and_return(particle)
        expect(particle).to receive(:call!).once { raise Laminar::ParticleStopped }

        flow.flow do
          step :step1
        end
        expect {
          flow.new.call(x: 1, y: 2)
        }.to raise_error(Laminar::ParticleStopped)
      end
    end
  end
end
