module Laminar
  module Flow
    RSpec.describe Branch do

      describe 'attributes' do
        let(:branch) { described_class.new('branch1') }
        it { expect(branch).to respond_to(:name, :condition, :condition_type) }
      end

      describe '#new' do
        describe 'branch name' do
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

        context 'when conditions specified' do
          it 'rejects invalid options' do
            expect {
              described_class.new('branch', bob: :scum)
            }.to raise_error(ArgumentError)
          end

          it 'creates with an if: condition' do
            instance = described_class.new('branch', if: :test_me)
            expect(instance.condition_type).to eq(:if)
            expect(instance.condition).to eq(:test_me)
          end

          it 'creates with an unless: condition' do
            instance = described_class.new('branch', unless: :test_me)
            expect(instance.condition_type).to eq(:unless)
            expect(instance.condition).to eq(:test_me)
          end

          it 'requires a symbol as condition target' do
            expect {
              described_class.new('branch', if: 'fofof')
            }.to raise_error(TypeError)
          end
        end
      end

      describe '#meets_condition?' do
        let(:target) { double('target') }

        context 'when branch is unconditional' do
          let(:branch) { described_class.new('branch1') }
          it 'always returns :true' do
            expect(branch.meets_condition?(target)).to be true
          end
        end

        context 'when branch if: conditional' do
          let(:branch) { described_class.new('branch1', if: :test_me) }

          it 'satisfies condition if target method returns :true' do
            expect(target).to receive(:test_me).once.with(no_args) { true }
            expect(branch.meets_condition?(target)).to be true
          end

          it 'handles truthy/falsey conditions' do
            expect(target).to receive(:test_me).once.with(no_args) { :banana }
            expect(branch.meets_condition?(target)).to be_truthy

            expect(target).to receive(:test_me).once.with(no_args) { nil }
            expect(branch.meets_condition?(target)).to be_falsey
          end
        end

        context 'when branch unless: conditional' do
          let(:branch) { described_class.new('branch1', unless: :test_me) }

          it 'satisfies condition if target method returns :true' do
            expect(target).to receive(:test_me).once.with(no_args) { false }
            expect(branch.meets_condition?(target)).to be true
          end
        end
      end
    end
  end
end
