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

For a complete description of the basic API of `CheckedRecord` see [the basic API speculation](specuations/basic_api.md)


## Checks

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
      field :count, check: :non_negative_integer # inspired by Erlang
      field :name,  check: String
    end
```

Again we could behave

```ruby :example Behaving again...
  expect{ TypedRecord.new(count: 0, name: "YHS") }.not_to raise_error 
    
```




# LICENSE

Copyright 2020 Robert Dober robert.dober@gmail.com

Apache-2.0 [c.f LICENSE](LICENSE)




