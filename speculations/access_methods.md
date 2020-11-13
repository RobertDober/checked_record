# Speculating about `CheckedRecord` Access Methods

## Context Simple Immutable, Unchecked

Given

```ruby :include
    class Access1 < CheckedRecord 
      field :a
      field :b
    end

    let(:instance1) {Access1.New(a: 1, b: 2)}
    let(:dummy) {Object.new}
```

### By Name

```ruby :example named access
  expect( instance1.a ).to eq(1)
  expect( instance1.b ).to eq(2)
```

### By Index

```ruby :example named access
  expect( instance1[:a] ).to eq(1)
  expect( instance1[:b] ).to eq(2)
```

### Respecting the Hash API

```ruby :example respecting the Hash API
  expect( instance1.to_h ).to eq(a: 1, b: 2)
  expect( instance1.slice(:a) ).to eq(a: 1)
  expect( instance1[:c]).to be_nil
  expect( instance1.fetch(:c){dummy} ).to eq(dummy)
  expect{ instance1.fetch(:c) }.to raise_error(KeyError)
  expect( instance1.keys ).to eq(%i{a b})
  expect( instance1.values ).to eq(%i{a b})
```

### Extending the Hash API

```ruby :example extending the Hash API
  expect( instance1.without(:a) ).to eq(b: 2)
```

### Merging is ok as it returns new instances

```ruby :include
    let(:instance2) {instance1.merge(b: 200)}
```

```ruby :example Merging immutable records
  expect( instance2.b ).to eq(200)
  expect( instance1.b ).to eq(2)
```

### Merging is stricter as for hashes

```ruby :example Merging is stricter as for hashes
  expect{ instance1.merge(c: 3) }
    .to raise_error(CheckedRecord::IllegalFieldName, /:c/)
```

### Mutable API is just not present...

```ruby :example 
    expect{ instance1.a = 42 }
      .to raise_error(NoMethodError)
    expect{ instance1[:a] = 42 }
      .to raise_error(NoMethodError)
```



### Handling Naming Conflicts

Field names take always precedence and might mask the API
For that reason the `_` proxy method gives **always** access to the API

First of all `CheckedRecord` assures that `_` is an illegal field name

```ruby :example Must not define a proxy field
  expect do
    Class.new(CheckedRecord) do
      field :_
    end
  end 
    .to raise_error(CheckedRecord::IllegalFieldName, /:_/)
```

And now let us demonstrate how the proxy works

```ruby :include
    class Hiding1 < CheckedRecord
      field :slice
      field :to_h
    end

    let(:hidden1) {Hiding1.new(slice: "slice", to_h: "to_h")}
```

Fields prevail

```ruby :example Fields prevail
   expect(hidden1.values).to eq(%w[slice to_h])
```

Proxy to the rescue

```ruby :example Proxy to the rescue
  x(hidden._.to_h).to eq(slice: "slice", to_h: "to_h")
  x(hidden._.slice(:slice)).to eq(slice: "slice")
```


## Context Simple Mutable, Unchecked




