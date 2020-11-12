# CheckedRecord

Checked Records Structs on Steroids

All specs from this documentation are verified with the [speculate_about](https://rubygems.org/gems/speculate_about) gem.

## Quick Starter Guide

### Context As Simple As It Gets

At first sight just like a subclass of a `Struct`

```ruby :include
    class MyStruct < CheckedRecord
      field :a
      field :b
    end
```

Well the constructor is nicer though:

```ruby :example At first sight
  expect( MyStruct.new(a: 1, b: 2).values_at(:a, :b) ).to eq([1, 2])
```

And is safer as you must not ommit a required field

```ruby :example But this wont pass!
  expect{ MyStruct.new(a: 1) }.to raise_error(ArgumentError, "missing: [:b]")

```


Oh but you prefer the _old_ way of doing things?

```ruby :example It's soooo has been
  expect( MyStruct.positional_new(1, 2).values_at(:a, :b) ).to eq([1, 2])
```

Which still gives you the additional safety described above

```ruby :example Still wont pass!
  expect{ MyStruct.positional_new(1) }.to raise_error(ArgumentError, "missing: [:b]")
```

### Context Defaults are nice

```ruby :include
    class MyRecord < CheckedRecord
      field :a
      field :b, default: 0
      def sum; a + b end
    end
```

And behave totally as expected, as long as you expect how they behave

```ruby :example first appearance of defaults (100M years ago as shown by new scientific evidence)
  expect( MyRecord.new(a: 42).sum ).to eq(42)
  expect( MyRecord.positional_new(41, 1).sum ).to eq(42)
```

#### Access by name or via the `[]` method

```ruby :include
    let(:record) {MyRecord.new(a: 41)}
```

```ruby :example update by name
    expect( record.sum ).to eq(41)
    record.b += 1
    expect( record.sum ).to eq(42)
```

```ruby :example update by []
    expect( record.sum ).to eq(41)
    record[:b] = 2
    expect( record.sum ).to eq(43)
```

### Context Access modes

We have seen above that fields can be read and written, however we can define readonly fields

```ruby :include
    class WithRO < CheckedRecord
      field :a, default: 42
      field :b, default: 0, readonly: true
    end
```


Initializing is ok, of course

```ruby :example initialization's ok
  expect( WithRO.new(b: 1)[:b] ).to eq(1)
```

However...

```ruby :example beware the changes
  expect{ WithRO.new(b: 1)[:b] = 2 }.to raise_error(KeyError, "must not modify readonly field :b")

```

For a complete description of the basic API of `CheckedRecord` see [the basic API speculation](speculations/basic_api.md)


## Context Checks

As the name indicates `CheckedRecord` is about, well _checks_.

So far we have only seen the tip of the iceberg, so let us have a look at how we can constrain our fields even more...

### Context General Constraint

A General Constraint is simply a block or lambda that will always called when a value is modified or initialized

```ruby :include
    class TotallyChecked < CheckedRecord
      field :positive do |value|
        Integer === value && value > 0
      end
    end
```

No everything is still fine, as long as we behave

```ruby :example sooo well behaved
  expect( TotallyChecked.new(positive: 2).to_h ).to eq(positive: 2)
```

Behold the Zero though

```ruby :example what a misstakea to makea
  expect{ TotallyChecked.new(positive: 0) }
    .to raise_error(CheckedRecord::ConstraintError, "illegal value 0 for field :positive")
```

#### And now for something completely different, types:

```ruby :include
    class TypedRecord < CheckedRecord
      field :count, check: :non_negative_int # inspired by Erlang
      field :name,  check: String
    end
```

Again we could behave...

```ruby :example Behaving again...
  expect{ TypedRecord.new(count: 0, name: "YHS") }.not_to raise_error 
    
```

...or not 

```ruby :example ...or not
  expect{ TypedRecord.new(count: 0, name: :yours) }
    .to raise_error(CheckedRecord::ConstraintError, "illegal value :yours for field :name")
    
```

### Context Compile Time Checks

It is interesting to note, that default values are checked at _compile time_, that is at the declaration
of the field

```ruby :example 
  expect do
    Class.new CheckedRecord do
      field :count, default: -1, check: :non_negative_int
    end
  end
    .to raise_error(CheckedRecord::ConstraintError, "illegal default value -1 for field :count")
```

Other things you wanna catch early

```ruby :example no more than once please
  expect do
    Class.new CheckedRecord do
      field :a
      field :a
    end
  end
    .to raise_error(ArgumentError, %r{\Afield :a already defined in})
    
```

For a complete description of the checking API of `CheckedRecord` see [the checking API speculation](./speculations/checking_api.md)

## Context Validations

Sofar we have only checked the value of a single field without a context, but as e.g. in `ActiveModel` we
want to be able to assert certain conditions involving more than one field, e.g.


Although this concise form might be convenient the general form of `validate` might be easier to write and to read

```ruby :include
    class OrderedPair < CheckedRecord
      field :a, check: Integer
      field :b, check: Integer
      validate [:a, :b], with: :validate_order 

      def validate_order
        if a > b
          "b must not be smaller than a but is (%s < %s)" % [b, a]
        end
      end
    end
```

The validation method `validate_order` will return `nil` exactly if
the validation succeeds, otherwise it returns the error message that will be added to the `ConstraintError` to
be risen.


```ruby :example a too bigly
    expect{ OrderedPair.new(a: 42, b: 41) }
      .to raise_error(CheckedRecord::ConstraintError, "b must not be smaller than a but is (41 < 42)")
```

For a complete description of the validation API of `CheckedRecord` see [the validation API speculation](./speculations/validation_api.md)

## Context Consistency

Let us assume we have a

```ruby :include
    class UbuntuName < CheckedRecord
      field :adjective, check: String
      field :animal, check: String
      validate :all, with: :legal_ubuntu_name

      def legal_ubuntu_name
        return if adjective[0] == animal[0]
        "Ubuntu Names must have the same initials"
      end
    end
```

### How to lose Consistent State

Now we create a new release

```ruby :include
    let(:zeberon) { UbuntuName.new(adjective: "zealous", animal: "zeberon")}
```

And now we break it

```ruby :example Breaking the Zeberon
  expect{ zeberon.animal = "Cerberon" }.to raise_error(CheckedRecord::ConstraintError) 
  expect( zeberon.animal ).to eq("Cerberon") # which is unfortunate
```

### Keeping Consistent State

#### Using immutability

##### `merge!` you guess why it did not work

If this is not too costly, and frankly it would rarely be, create a new object with the new values, thusly
leaving the receiver unchanged

```ruby :example Immutable Zeberons Stay Forever
  cerberon = zeberon.merge!(animal: "cerberon")
  expect( cerberon ).to be_nil
  expect( zeberon.animal ).to eq("zeberon")
```

Now if you do it right of course ;)


```ruby :example Cerberon Ex Macchina
  cerberon = zeberon.merge!(adjective: "cynomagical", animal: "cerberon")
  expect( zeberon.animal ).to eq("zeberon")
  expect( cerberon.to_h ).to eq(adjective: "cynomagical", animal: "cerberon")
```

##### `merge` I tell you what went wrong

In case of errors we might want to have some error information, in that case we can use merge

```ruby :example Tell me why
  status, cerberon = zeberon.merge(animal: "cerberon")
  expect(status).to eq(:error)
  expect( cerberon ).to eq("") 
  expect( zeberon.animal ).to eq("zeberon")
```

# LICENSE

Copyright 2020 Robert Dober robert.dober@gmail.com

Apache-2.0 [c.f LICENSE](LICENSE)
