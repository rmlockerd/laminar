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

        context 'when passed a block (not steps)' do
          let(:bogus_block) { Proc.new { floopy } }
          let(:step) { instance_double('Laminar::Flow::Step', name: :my_step) }

          it 'raises and error' do
            expect {
              described_class.new(:my_step, &bogus_block)
            }.to raise_error(NameError)
          end
        end
      end

      describe '#step' do
        let(:spec) { described_class.new }
        let(:step1) { instance_double('Laminar::Flow::Step', name: :step1) }

        it 'creates a new step' do
          expect(Laminar::Flow::Step).to receive(:new).once
                                                      .with(:step1, {}) { step1 }
          spec.step(:step1)
          expect(spec.steps.size).to be 1
          expect(spec.steps.keys).to include(:step1)
          expect(spec.first_step).to eq(:step1)
        end

        context 'when there is a step' do
          let(:spec) { described_class.new }
          let(:step1) { instance_double('Laminar::Flow::Step', name: :step1) }
          let(:step2) { instance_double('Laminar::Flow::Step', name: :step2) }

          it 'links from the last step' do
            expect(Laminar::Flow::Step).to receive(:new).once
                                                        .with(:step1, {}) { step1 }
            expect(Laminar::Flow::Step).to receive(:new).once
                                                        .with(:step2, {}) { step2 }
            expect(step1).to receive(:branch).once.with(:step2) { [step2] }
            spec.step(:step1)
            spec.step(:step2)
          end
        end
      end
    end
  end
end
