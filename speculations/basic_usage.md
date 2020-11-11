# CheckedRecord

## Basic Use Case

A really simple usage of `CheckedRecord` would look like this:

```ruby :include
    require "checked_record"
    class BasicRecord < CheckedRecord
      field :a
      field :b
    end
```

However this is not the same as

```ruby
    BasicRecord = Struct.new(:a, :b)
```

as we can see here:

```ruby :include
    let(:instance){BasicRecord.new(a: 1, b: 2)}
```

Now we can read and write the two fields freely, that is _unchecked_:

```ruby :example Free read/write access
  expect( instance.a ).to eq(1)
  expect( instance.b ).to eq(2)
  expect( instance[:a] ).to eq(1)
  expect( instance[:b] ).to eq(2)
  expect( instance.values_at(:b, :a)).to eq([2, 1])
  expect( instance.to_h ).to eq(a: 1, b: 2)
```

And after changing

```ruby :example Changing a CheckedRecord instance
  instance.a = 11
  instance.b += 10
  expect( instance.a ).to eq(11)
  expect( instance.b ).to eq(12)
```




