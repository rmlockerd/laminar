module Laminar
  RSpec.describe Particle do
    let(:particle) { Class.new.send(:include, described_class) }

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

      it 'raises ParticleFailed errors' do
        expect(instance).to receive(:invoke!).and_raise(Laminar::ParticleFailed)
        expect {
          instance.invoke
        }.to_not raise_error(Laminar::ParticleFailed)
      end

      it 'propagates ordinary errors' do
        expect(instance).to receive(:invoke!).and_raise(StandardError)
        expect {
          instance.invoke
        }.to raise_error(StandardError)
      end
    end

    describe '#invoke!' do
      context 'when particle specifies keyword args' do
        let(:arg_particle) { MockParticle::WithKeywordArgs.new(x: 1, y: 2, z: 3) }
        let(:missing_particle) { MockParticle::WithKeywordArgs.new(x: 1) }

        it 'runs the particle' do
          expect(arg_particle).to receive(:call).once.with(hash_including(x: 1,
                                                                          y: 2))
          arg_particle.invoke!
        end

        it 'passes only required context as arguments' do
          expect(arg_particle).to receive(:call).once.with(hash_excluding(z: 3))
          arg_particle.invoke!
        end

        it 'raises error if required context missing' do
          expect {
            missing_particle.invoke!
          }.to raise_error(ArgumentError)
        end
      end

      context 'when particle specifies optional keyword args' do
        let(:all_args) { MockParticle::WithOptionalArgs.new(x: 1, y: 2) }
        let(:only_reqd) { MockParticle::WithOptionalArgs.new(x: 1) }
        let(:no_args) { MockParticle::WithOptionalArgs.new }

        it 'runs the particle (only required)' do
          expect(all_args).to receive(:call).once.with(hash_including(x: 1,
                                                                       y: 2))
          all_args.invoke!
        end

        it 'runs the particle (all arguments)' do
          expect(only_reqd).to receive(:call).once.with(hash_including(x: 1))
          only_reqd.invoke!
        end

        it 'raises error if required context missing' do
          expect {
            no_args.invoke!
          }.to raise_error(ArgumentError)
        end
      end

      context 'when particle specifies no arguments' do
        let(:instance) { particle.new }

        it "calls the interactor" do
          expect(instance).to receive(:call).once.with(no_args)
          instance.invoke!
        end

        it "raises ParticleFailed errors" do
          expect(instance).to receive(:invoke!).and_raise(Laminar::ParticleFailed)
          expect {
            instance.invoke!
          }.to raise_error(Laminar::ParticleFailed)
        end

        it 'propagates ordinary errors' do
          expect(instance).to receive(:invoke!).and_raise(StandardError)
          expect {
            instance.invoke!
          }.to raise_error(StandardError)
        end
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
end
