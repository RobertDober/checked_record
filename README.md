# CheckedRecord

Checked Records Structs on Steroids

## Quick Starter Guide

### As Simple As It Gets

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

### Defaults are nice

```ruby :include
    class MyRecord < CheckedRecord
      field :a
      field :b, default: 0
      def sum; a + b end
    end
```

And behave totally as expected, as long as you expect how they behave

```ruby :example 
  expect( MyRecord.new(a: 42).sum ).to eq(42)
  expect( MyRecord.positional_new(41, 1).sum ).to eq(42)
```





