# Laminar

[![Gem Version](https://badge.fury.io/rb/laminar.svg)](https://badge.fury.io/rb/laminar)
[![Build Status](https://travis-ci.org/rmlockerd/laminar.svg?branch=master)](https://travis-ci.org/rmlockerd/laminar)
[![Maintainability](https://api.codeclimate.com/v1/badges/6b2d761ca042af6461e3/maintainability)](https://codeclimate.com/github/rmlockerd/laminar/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/6b2d761ca042af6461e3/test_coverage)](https://codeclimate.com/github/rmlockerd/laminar/test_coverage)

A simple Chain-of-Responsibility/Interactor gem that helps MVC applications organise their business logic, keeping their models and controllers skinny and their logic easily testable. Individual chunks of business logic (called particles) can be easily composed into more complex chains called flows.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'laminar'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install laminar

## Usage
### 'Skinny' Controllers AND 'Skinny' Models

Even if you are reasonably new to Model-View-Controller (MVC) frameworks, such as Ruby on Rails, you have likely encountered the advice to have 'skinny controllers, fat models'. 'Skinny' controllers (i.e., simple, small, single-responsibility) are indeed best, but pushing a lot of code into your models has its own issues, and it isn't in reality an either/or choice.

Separating your business logic into single-purpose service objects (also sometimes called 'interactors' and several other names) helps keep your models and controllers skinny, and your code DRY and more easily testable.

### Particles

A particle is a PORO (Plain Old Ruby Object) that encapsulates a piece of your business logic. Keeping with the Single Responsibility Principle, a particle should preferably do only one thing.

#### Defining a Particle
A particle is a plain Ruby class that includes `Laminar::Particle` and defines a `call` method.

```ruby
class ChangeAddress
  include Laminar::Particle

  def call
    // change address logic goes here
  end
end
```

#### Particle Context

To invoke a particle, invoke the `.call` method on the particle's
class object, passing a Hash of values that is the 'context' in which
the particle runs.
```ruby
ChangeAddress.call(user: user, new_address: addr)
```

The invoked particle accesses its context within its `.call` method like  normal Hash:
```ruby
sku = context[:product_sku]
```

The particle can also add to or modify the context. The context is returned to the invoker, which can then access the modified context.

```ruby
// Particle
class OpenTicket
  include Laminar::Particle

  def call
    context[:status] = :pending
  end
end

// Caller
result = OpenTicket.call
if result[:status] != :pending
  ...
end
```

#### Keyword Arguments

You can also use keyword arguments particle's `.call` method:
```ruby
class ChangeAddress
  include Laminar::Particle

  def call(user:, new_address:)
    // change address logic goes here
  end
end
```

When you declare keyword arguments, Laminar passes matching values
from the context to your particle. This can make your particle more
self-documenting and provides a simple `ArgumentError` exception if the
calling context does not contain the minimum information required for the
particle to function.

The `.call` implementation always has access to the full context via
`context` whether or not you declare keyword arguments.

#### Particle Success / Failure
Particles have a simple mechanism for flagging success and
failure. To signal failure, simply call `.fail!` on the context.
```ruby
context.fail!
```

There are also convenience methods for checking success/failure:
```ruby
context.success? # => true by default
context.failed? # => false

context.fail!

context.halted? # => true
context.failed? # => true
context.success? # => false
```

The `.fail!` method accepts a hash that is merged into the context,
making it convenient to attach error information:
```ruby
context.fail!(error: 'The user is allergic to bananas!')
```

Use the `.halt!` class method to immediately stop a particle without marking it as a failure.

```ruby
context.halt!

context.halted? # => true
context.success? # => true
context.failed? # => false
```

The `.halt!` accepts a context hash similar to `.fail!`.

#### Callbacks

Particles can specify one or more callbacks to execute immediately before or after the invocation of its `#call`.

```ruby
class Foo
  include Laminar::Flow

  before :setup  # method symbol
  before { ... } # block

  after :teardown  # method symbol
  after { ... } # block
```
Callbacks execute in the order they are specified when there are multiple of the same kind.

### Flows

A flow is a chained sequence of particles, creating a simple workflow.
Each step (particle) contributes to an overall outcome through a shared
context. Simple branching and looping is supported via conditional
logic.

A flow includes `Laminar::Flow`, which provides a DSL for specifying
the particles to execute. The most basic flow is a simple set of steps executed sequentially.

```ruby
class FillCavity
  include Laminar::Flow

  flow do
    step :numb_mouth
    step :drill_cavity
    step :apply_amalgam
  end
end
```

A step label must be a symbol that identifies a Particle. By default,
the Flow assumes the step label is the implementation class name (i.e.,
`:numb_mouth` -> `NumbMouth`).
You can use the `class:` directive to specify an alternate class
name. Very useful when your particles
are organised into modules.
```ruby
class FillCavity
  include Laminar::Flow

  flow do
    step :numb_mouth
    step :drill_cavity, class: 'Dentist::Drill'
    step :apply_amalgam
  end
end
```

#### Invoking a Flow
Flows behave exactly like Particles in terms of execution. To start
a Flow, call `.call` on the Flow class, passing a Hash of context:

```ruby
// Flow
class FillCavity
  include Laminar::Flow

  flow do
    step :numb_mouth
    step :drill_cavity, class: 'Dentist::Drill'
    step :apply_amalgam
  end
end

// Caller
result = FillCavity.call(patient: patient, tooth_number: tooth)
```

A Flow returns the context as it stands after the final step in the
Flow ends. Because Flows behave exactly like Particles, they can be
nested as steps inside other flows without issue:

```ruby
class FillCavity
  include Laminar::Flow

  flow do
    step :check_equipment # Flow
    ...
  end
end

class CheckEquipment
  include Laminar::Flow

  flow do
    ...
  end
end
```

#### Flow Parameters
Flows do not get the benefit of keyword argument checking like ordinary
Particles, since their #call method is implemented by the Flow mixin.
You can, however, specify a list of required context keys in the flow
definition itself:

```ruby
flow do
  context_must_have :product_sku, :unit_price
  ...
end
```

The context is simply checked for the presence of the specified
list of keys. If you need to do more complicated validation of
context, use a ``#before`` callback that halts the flow if
validation fails.

Context validation happens just prior to execution of the
first step in the flow (and any ``#before_each``) callbacks, but after
execution of the Flow's own ``#before`` callbacks. Since you can
manipulate context in a callback, this is useful to set up
context required by a flow's particles that you don't necessarily
expect your caller to provide.

#### Flow Branching
Ordinarily particle execution is sequential in the order specified.
However, you can optionally branch to a different label with `branch`.
```ruby
  flow do
    step :do_something do
      branch :final_step      
    end
    step :another_step # skipped
    step :final_step
  end
```

You can use the endflow directive to terminate the flow gracefully
(skipping all remaining steps).

```ruby
  flow do
    step :do_something do
      branch :endflow
    end
    step :another_step # skipped
    step :final_step # skipped
  end
```

#### Conditional Branching

Branches can be made conditional with the `if:` and `unless:`
directives.

```ruby
  flow do
    step :first do
      branch :last_step, if: :done_early?      
    end
    step :then_me
    step :do_something
    step :last_step
  end
```

The target of `if:` or `unless:` is a symbol naming a method on the invoking Flow.

```ruby
  flow do
    step :first do
      branch :last_step, if: :done_early?      
    end
    ...
  end

  def done_early?
    !context[:finished].nil? && context[:finished] == true
  end
```

A step can have multiple branch directives; the flow will take the first
branch that it finds that satisfies its specified condition (if any). If
no condition is satisfied, execution drops to the next step.

```ruby
  flow do
   step :first do
     branch :last_step, if: :condition1?
     branch :do_something, if: :condition2?
   end
   step :then_me # executed if neither condition1 nor condition2
   step :do_something
   step :last_step
  end
```
#### Halting a Flow
If a particle calls ``#halt!`` or ``#fail!`` on its context, execution
of any surrounding Flow (or nested flows) stops immediately via a
``ParticleStopped`` error. To gracefully signal that an enclosing
flow should stop without raising an error, use ``#halt`` instead.

#### Flow Callbacks

A flow can specify callback(s) to run before/after every step:

```ruby
class MyFlow
  include Laminar::Flow

  flow do
    before_each :thing, :thing2  # method
    before_each { ... } # block

    after_each :thing, :thing2  # method
    after_each { ... } # block

    # steps ...
  end
```

The order of execution for callbacks in a flow looks like:

```
flow's before
  flow's before_each
    step1's before
      <step1 invoked>
    step1's after
  flow's after_each
flow's after
```

#### Testing Particles and Flows

TODO

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/rmlockerd/laminar. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to
adhere to the [Contributor Covenant](http://contributor-covenant.org) code
of conduct.

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Laminar project’s codebases, issue trackers,
chat rooms and mailing lists is expected to follow the
[code of conduct]
(https://github.com/rmlockerd/laminar/blob/master/CODE_OF_CONDUCT.md).
