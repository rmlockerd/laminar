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

      describe '#before_each' do
        context 'when list of symbols' do
          let(:spec) { described_class.new }
          it 'adds all symbols to the before queue' do
            expect {
              spec.before_each(:before1, :before2, :before3)
            }.to change {
              spec.before_each_callbacks
            }.from([]).to([:before1, :before2, :before3])
          end
        end

        context 'when a block' do
          let(:spec) { described_class.new }
          it 'adds the block to the before queue' do
            expect {
              spec.before_each do
                x = x + 1
              end
            }.to change {
              spec.before_each_callbacks
            }.from([])
          end
        end

        context 'when list of symbols + a block' do
          let(:spec) { described_class.new }
          let(:result) {
            spec.before_each(:before1, :before2) do
              x = x + 1
            end
          }

          it 'adds the symbols to the before queue' do
            expect(result).to include(:before1, :before2)
          end

          it 'adds the block to the before queue' do
            expect(result.last).to be_a(Proc)
          end
        end

        context 'when called multiple times' do
          let(:spec) { described_class.new }

          it 'adds everything to the before queue' do
            expect {
              spec.before_each(:before1)
              spec.before_each(:before2)
              spec.before_each(:before3)
            }.to change {
              spec.before_each_callbacks
            }.from([]).to([:before1, :before2, :before3])
          end
        end
      end

      describe '#after_each' do
        context 'when list of symbols' do
          let(:spec) { described_class.new }
          it 'adds all symbols to the after queue' do
            expect {
              spec.after_each(:after1, :after2, :after3)
            }.to change {
              spec.after_each_callbacks
            }.from([]).to([:after1, :after2, :after3])
          end
        end

        context 'when a block' do
          let(:spec) { described_class.new }
          it 'adds the block to the after queue' do
            expect {
              spec.after_each do
                x = x + 1
              end
            }.to change {
              spec.after_each_callbacks
            }.from([])
          end
        end

        context 'when list of symbols + a block' do
          let(:spec) { described_class.new }
          let(:result) {
            spec.after_each(:after1, :after2) do
              x = x + 1
            end
          }

          it 'adds the symbols to the after queue' do
            expect(result).to include(:after1, :after2)
          end

          it 'adds the block to the after queue' do
            expect(result.last).to be_a(Proc)
          end
        end

        context 'when called multiple times' do
          let(:spec) { described_class.new }

          it 'adds everything to the after queue' do
            expect {
              spec.after_each(:after1)
              spec.after_each(:after2)
              spec.after_each(:after3)
            }.to change {
              spec.after_each_callbacks
            }.from([]).to([:after1, :after2, :after3])
          end
        end
      end

      describe '#context_must_have' do
        let(:spec) { described_class.new }

        it 'adds to the flow parameter list' do
          expect {
            spec.context_must_have([:key1, 'key2', :key3])
          }.to change {
            spec.flow_params
          }.from([]).to([:key1, 'key2', :key3])
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
