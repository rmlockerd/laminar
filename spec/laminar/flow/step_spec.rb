module Laminar
  module Flow
    RSpec.describe Step do
      describe 'attributes' do
        let(:step) { described_class.new(:step1) }
        it { expect(step).to respond_to(:name, :branches, :class_name, :particle) }
      end

      describe '#new' do
        describe 'step name' do
          it 'requires a name' do
            expect { described_class.new }.to raise_error(ArgumentError)
          end

          it 'requires a symolizable name' do
            expect { described_class.new(0) }.to raise_error(ArgumentError)
            expect { described_class.new(['foo']) }.to raise_error(ArgumentError)
            expect { described_class.new(nil) }.to raise_error(ArgumentError)
            expect { described_class.new('foo') }.to_not raise_error
            expect { described_class.new(:foo) }.to_not raise_error
          end
        end

        context 'when invalid options specified' do
          it 'raises error' do
            expect {
              described_class.new('step1', bob: :scum)
            }.to raise_error(ArgumentError)
          end
        end

        context 'when no :class specified' do
          let(:step) { described_class.new('step1') }

          it 'uses step name as default class' do
            expect(step.class_name).to eq('step1'.camelize)
          end
        end

        context 'when :class specified' do
          let(:step) { described_class.new(:step1, class: 'Bunny::Floppy') }

          it 'uses the specified class name' do
            expect(step.class_name).to eq('Bunny::Floppy')
          end
        end

        context 'when passed a block of branches' do
          let(:branch_block) { Proc.new { branch :endflow } }
          let(:branch) { instance_double('Laminar::Flow::Branch', name: :endflow) }

          it 'creates branches' do
            expect(Laminar::Flow::Branch).to receive(:new).once
                                                          .with(:endflow, {}) { branch }
            step = described_class.new(:step1, &branch_block)
            expect(step.branches.size).to be 1
            expect(step.branches).to include(branch)
          end
        end
        context 'when passed a block (not branches)' do
          let(:branch_block) { Proc.new { floopy } }
          let(:branch) { instance_double('Laminar::Flow::Branch', name: :endflow) }

          it 'raises and error' do
            expect {
              described_class.new(:step1, &branch_block)
            }.to raise_error(NameError)
          end
        end
      end

      describe '#before' do
        context 'when list of symbols' do
          let(:step) { described_class.new(:step1) }
          it 'adds all symbols to the before queue' do
            expect {
              step.before(:before1, :before2, :before3)
            }.to change {
              step.before_callbacks
            }.from([]).to([:before1, :before2, :before3])
          end
        end

        context 'when a block' do
          let(:step) { described_class.new(:step1) }
          it 'adds the block to the before queue' do
            expect {
              step.before do
                x = x + 1
              end
            }.to change {
              step.before_callbacks
            }.from([])
          end
        end

        context 'when list of symbols + a block' do
          let(:step) { described_class.new(:step1) }
          let(:result) {
            step.before(:before1, :before2) do
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
          let(:step) { described_class.new(:step1) }

          it 'adds everything to the before queue' do
            expect {
              step.before(:before1)
              step.before(:before2)
              step.before(:before3)
            }.to change {
              step.before_callbacks
            }.from([]).to([:before1, :before2, :before3])
          end
        end
      end

      describe '#after' do
        context 'when list of symbols' do
          let(:step) { described_class.new(:step1) }
          it 'adds all symbols to the after queue' do
            expect {
              step.after(:after1, :after2, :after3)
            }.to change {
              step.after_callbacks
            }.from([]).to([:after1, :after2, :after3])
          end
        end

        context 'when a block' do
          let(:step) { described_class.new(:step1) }
          it 'adds the block to the after queue' do
            expect {
              step.after do
                x = x + 1
              end
            }.to change {
              step.after_callbacks
            }.from([])
          end
        end

        context 'when list of symbols + a block' do
          let(:step) { described_class.new(:step1) }
          let(:result) {
            step.after(:after1, :after2) do
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
          let(:step) { described_class.new(:step1) }

          it 'adds everything to the after queue' do
            expect {
              step.after(:after1)
              step.after(:after2)
              step.after(:after3)
            }.to change {
              step.after_callbacks
            }.from([]).to([:after1, :after2, :after3])
          end
        end
      end

      describe '#branch' do
        let(:step) { described_class.new(:step1, class: 'Bunny::Floppy') }
        let(:branch) { instance_double('Laminar::Flow::Branch') }

        it 'creates a branch' do
          expect(Laminar::Flow::Branch).to receive(:new).once
                                                        .with(:bname, {}) { branch }
          expect(step.branch(:bname)).to include(branch)
        end

        it 'adds the branch to the branch list' do
          expect(Laminar::Flow::Branch).to receive(:new).once
                                                        .with(:bname, {}) { branch }
          step.branch(:bname)
          expect(step.branches.size).to be 1
          expect(step.branches).to include(branch)
        end
      end

      describe '#next_step_name' do
        let(:step) { described_class.new(:step1) }
        let(:branch) { instance_double('Laminar::Flow::Branch', name: :bname) }
        let(:target) { double(:target) }

        context 'when step has no branches' do
          it 'returns nil' do
            expect(step.next_step_name(target)).to be nil
          end
        end

        context 'when step has no matching branches' do
          it 'returns nil' do
            expect(Laminar::Flow::Branch).to receive(:new).once
                                                          .with(:bname, {}) { branch }
            expect(branch).to receive(:meets_condition?).once.with(target) { false }
            step.branch(:bname)
            expect(step.next_step_name(target)).to be nil
          end
        end

        context 'when step has a matching branch' do
          it 'returns the branch name' do
            expect(Laminar::Flow::Branch).to receive(:new).once
                                                          .with(:bname, {}) { branch }
            expect(branch).to receive(:meets_condition?).once.with(target) { true }
            step.branch(:bname)
            expect(step.next_step_name(target)).to eq(:bname)
          end
        end
      end

      describe '#first_applicable_branch' do
        let(:step) { described_class.new(:step1) }
        let(:branch) { instance_double('Laminar::Flow::Branch') }
        let(:target) { double(:target) }

        context 'when step has no branches' do
          it 'returns nil' do
            expect(step.first_applicable_branch(target)).to be nil
          end
        end

        context 'when step has no matching branches' do
          it 'returns nil' do
            expect(Laminar::Flow::Branch).to receive(:new).once
                                                          .with(:bname, {}) { branch }
            expect(branch).to receive(:meets_condition?).once.with(target) { false }
            step.branch(:bname)
            expect(step.first_applicable_branch(target)).to be nil
          end
        end

        context 'when step has a matching branch' do
          it 'returns the matching branch' do
            expect(Laminar::Flow::Branch).to receive(:new).once
                                                          .with(:bname, {}) { branch }
            expect(branch).to receive(:meets_condition?).once.with(target) { true }
            step.branch(:bname)
            expect(step.first_applicable_branch(target)).to eq(branch)
          end
        end
      end
    end
  end
end
