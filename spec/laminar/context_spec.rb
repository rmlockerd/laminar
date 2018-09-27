module Laminar
  RSpec.describe Context do
    describe '.build' do
      let(:context) { described_class.build(x: 1, y: 2, z: 3) }

      it 'returns a new context' do
        context = Laminar::Context.build(x: 120)
        expect(context).to be_a(Laminar::Context)
        expect(context).to include(x: 120)
      end
    end

    describe '#halt!' do
      let(:context) { described_class.build(x: 1, y: 2, z: 3) }

      it 'marks the context halted' do
        expect {
          context.halt! rescue ParticleStopped
        }.to change { context.halted? }.from(false).to(true)
      end

      it 'merges hashed arguments into context' do
        context.halt!(status: :done) rescue ParticleStopped
        expect(context).to include(status: :done)
      end

      it 'preserves success' do
        context.halt! rescue ParticleStopped
        expect(context.success?).to be true
      end

      it 'does not change failure status' do
        expect {
          context.halt! rescue ParticleStopped
        }.to_not change { context.failed? }
      end
    end

    describe '#fail!' do
      let(:context) { described_class.build(x: 1, y: 2, z: 3) }

      it 'raises an error' do
        expect {
          context.fail!
        }.to raise_error(Laminar::ParticleStopped)
      end

      it 'marks the context failed' do
        expect {
          context.fail! rescue Laminar::ParticleStopped
        }.to change { context.failed? }.from(false).to(true)
      end

      it 'sets success false' do
        expect {
          context.fail! rescue Laminar::ParticleStopped
        }.to change { context.success? }.from(true).to(false)
      end

      it 'marks the context halted' do
        expect {
          context.fail! rescue Laminar::ParticleStopped
        }.to change { context.halted? }.from(false).to(true)
      end

      it 'merges arguments into context' do
        context.fail!(status: :done) rescue Laminar::ParticleStopped
        expect(context).to include(status: :done)
      end

      it 'does not affect original context' do
        expect {
          context.fail!(status: :done) rescue Laminar::ParticleStopped
        }.to_not change { context[:x] }
      end
     end
  end
end
