module Laminar
  module Flow
    RSpec.describe Specification do
      describe 'attributes' do
        let(:spec) { described_class.new }
        it { expect(spec).to respond_to(:steps, :first_step) }
      end

      describe '#new' do
        let(:spec) { described_class.new }
        it 'creates an empty specification' do
          expect(spec.first_step).to be nil
          expect(spec.steps).to be_empty
        end

        context 'when supplied with a block of steps' do
          let(:step_block) { Proc.new { step :step1 } }
          let(:step1) { instance_double('Laminar::Flow::Step', name: :step1) }

          it 'creates steps' do
            expect(Laminar::Flow::Step).to receive(:new).once
                                                        .with(:step1, {}) { step1 }
            spec = described_class.new(&step_block)
            expect(spec.steps.size).to be 1
            expect(spec.steps.keys).to include(:step1)
            expect(spec.first_step).to eq(:step1)
          end
        end
      end
    end
  end
end
