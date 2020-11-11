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

### Access by name or via the `[]` method

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



## LICENSE

Copyright 2020 Robert Dober robert.dober@gmail.com

Apache-2.0 [c.f LICENSE](LICENSE)




