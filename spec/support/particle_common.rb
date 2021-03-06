# Flows are also themselves Particles. These unit test specs are common
# across both.
RSpec.shared_examples 'particle_common' do
  let(:particle) { Class.new.send(:include, described_class) }

  describe '.before' do
    context 'when callback is a symbol' do
      it 'adds to the before list' do
        particle.before(:foo_berry)
        expect(particle.before_list).to include(:foo_berry)
      end

      it 'appends to existing callbacks' do
        particle.before(:foo_berry)
        particle.before(:rum_ripple)
        expect(particle.before_list).to contain_exactly(:foo_berry, :rum_ripple)
      end
    end

    context 'when callback is a block' do
      it 'adds to the before list' do
        particle.before {context[:foo] = :bar}
        expect(particle.before_list.first).to be_a(Proc)
      end
    end
  end

  describe '.after' do
    context 'when callback is a symbol' do
      it 'adds to the after list' do
        particle.after(:foo_berry)
        expect(particle.after_list).to include(:foo_berry)
      end

      it 'appends to existing callbacks' do
        particle.after(:foo_berry)
        particle.after(:rum_ripple)
        expect(particle.after_list).to contain_exactly(:foo_berry, :rum_ripple)
      end
    end

    context 'when callback is a block' do
      it 'adds to the after list' do
        particle.after {context[:foo] = :bar}
        expect(particle.after_list.first).to be_a(Proc)
      end
    end
  end

  describe '.call' do
    let(:context) { instance_double('Laminar::Context') }
    let(:inst) { double(:inst, context: context) }

    it 'creates an instance and passes the given context' do
      expect(particle).to receive(:new).once.with(bob: :scum) { inst }
      expect(inst).to receive(:invoke).once.with(no_args) { inst.context }

      expect(particle.call(bob: :scum)).to eq(context)
    end

    it 'creates a blank context if none given' do
      expect(particle).to receive(:new).once.with({}) { inst }
      expect(inst).to receive(:invoke).once.with(no_args) { inst.context }
      expect(particle.call()).to eq(context)
    end
  end

  describe '.call!' do
    let(:context) { instance_double('Laminar::Context') }
    let(:inst) { double(:inst, context: context) }

    it 'creates an instance and passes the given context' do
      expect(particle).to receive(:new).once.with(bob: :scum) { inst }
      expect(inst).to receive(:invoke!).once.with(no_args) { inst.context }
      expect(particle.call!(bob: :scum)).to eq(context)
    end

    it 'creates a blank context if none given' do
      expect(particle).to receive(:new).once.with({}) { inst }
      expect(inst).to receive(:invoke!).once.with(no_args) { inst.context }
      expect(particle.call!()).to eq(context)
    end
  end

  describe '#new' do
    let(:context) { instance_double('Laminar::Context') }

    it 'creates a context' do
      expect(Laminar::Context).to receive(:build).once.with(bad: :wolf) { context }
      inst = particle.new(bad: :wolf)
      expect(inst).to be_a(particle)
      expect(inst.context).to eq(context)
    end

    it 'creates an empty context if none given' do
      expect(Laminar::Context).to receive(:build).once.with(bad: :wolf) { context }
      inst = particle.new(bad: :wolf)
      expect(inst).to be_a(particle)
      expect(inst.context).to eq(context)
    end
  end

  describe '#invoke' do
    let(:instance) { particle.new }

    it 'raises ParticleStopped errors' do
      expect(instance).to receive(:invoke!).and_raise(Laminar::ParticleStopped)
      expect {
        instance.invoke
      }.to_not raise_error(Laminar::ParticleStopped)
    end

    it 'propagates ordinary errors' do
      expect(instance).to receive(:invoke!).and_raise(StandardError)
      expect {
        instance.invoke
      }.to raise_error(StandardError)
    end
  end

  describe '#invoke! (default)' do
    let(:instance) { particle.new }

    it "calls the particle" do
      expect(instance).to receive(:call).once.with(no_args)
      instance.invoke!
    end

    it "raises ParticleStopped errors" do
      expect(instance).to receive(:invoke!).and_raise(Laminar::ParticleStopped)
      expect {
        instance.invoke!
      }.to raise_error(Laminar::ParticleStopped)
    end

    it 'propagates ordinary errors' do
      expect(instance).to receive(:invoke!).and_raise(StandardError)
      expect {
        instance.invoke!
      }.to raise_error(StandardError)
    end
  end

  describe '#call' do
    let(:instance) { particle.new }

    it 'has a default implementation' do
      expect(instance).to respond_to(:call)
      expect { instance.method(:call) }.not_to raise_error
      expect { instance.call }.not_to raise_error
    end
  end
end
