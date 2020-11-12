# `CheckedRecord` 

What is it?

I cannot explain, but Ruby can

## Some First Impressions

If you want a `Struct` with a nicer and saver constructor

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

Look Ma', no mutations

```ruby :include
    class ImmutablePerson < CheckedRecord
      field :name, type: String
      field :age,  type: :non_negative_int
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


Eagly eyed as you are you have spotted these `types` there, right?

```ruby :example Types, really?
  expect { ImmutablePerson.new(name: 42, age: "mine")}
    .to raise_error(CheckedRecord::ConstraintError, /illegal value 42 for field :name\nillegal value "mine" for field :age/)
    
```




## Quick Start Guide

# LICENSE

Copyright 2020 Robert Dober robert.dober@gmail.com

Apache-2.0 [c.f LICENSE](LICENSE)
