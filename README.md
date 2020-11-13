# `CheckedRecord` 

What is it?

Well depends on how you use it. Let us examine some of the possibilities

## `CheckedRecord` is ...

### Context ... a `Struct` with a nicer and stricter constuctor


```ruby :include
  class StructlikePerson < CheckedRecord
    mutable!
    field :name
    field :age
  end
```

Now you must provide both fields in the constructor

```ruby :example Missing your age badly

  expect{ StructlikePerson.new(name: "myself") }
    .to raise_error(ArgumentError, "missing: [:age]")
    
```

However not much more safety here:

```ruby :example Got I confused?
  expect( StructlikePerson.new(name: 42, age: "myself").to_h )
    .to eq(name: 42, age: "myself")
    
```

Oh and what was that `mutable!` for?

Maybe you guessed, let's verify 

```ruby :include
    let(:mutable_me) {StructlikePerson.new(name: "me", age: 42)}
```

```ruby :example It is indeed mutable
    expect( mutable_me.age ).to eq(42)
    mutable_me.age += 1
    expect( mutable_me.age ).to eq(43)
```

### Context ... an immutable `Struct` 

```ruby :include
    class ImmutablePerson < CheckedRecord
      field :name
      field :age
    end

    let(:immutable_me) { ImmutablePerson.new(name: "me", age: 42)}
```

And now:

```ruby :example No more aging here
    expect{ immutable_me.age += 1 }.to raise_error(NoMethodError)
```

maybe?

```ruby :example Nice try
  expect{ immutable_me[:age] = 43 }.to raise_error(CheckedRecord::ImmutableError)
```

Nice try but no!

The access methods to `CheckedRecord` instances are described here [speculations about access methods](speculations/access_methods.md)  

### Context ... a (type) checked `Struct` 

By using the `type:` or `check:` keyword (use whatever seems more readable, they are aliases)
one can assure that fields always adhere to certain contracts

```ruby :example Types, really?
  expect { ImmutablePerson.new(name: 42, age: -1)}
    .to raise_error(CheckedRecord::ConstraintError, /illegal value 42 for field :name\nillegal value -1 for field :age/)
    
```

The `type:` keyword is AAMOF an alias of `check:`, which, yeah, we can check out as follows

```ruby :include
    class MyChecks < CheckedRecord
      include_helpers for: %i{checks}
      mutable!
      field :the_answer, default: 42, check: ->(value){value == 42} # Well kinda of a dogma
      field :the_question, default: "The meaning of life, the universe and everything", check: method(:check_question) 

      def check_question maybe_legal_question
        maybe_legal_question[%r{meaning}i] &&
        maybe_legal_question[%r{life}i] &&
        maybe_legal_question[%r{universe}i] &&
        maybe_legal_question[%r{everything}i]
      end
    end
```





## Quick Start Guide

# LICENSE

Copyright 2020 Robert Dober robert.dober@gmail.com

Apache-2.0 [c.f LICENSE](LICENSE)
