module Laminar
  RSpec.describe Particle do
    include_examples 'particle_common'

    describe '#invoke! (keyword args)' do
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
    end
  end
end
