# Speculating about `CheckedRecord`'s Meta and Introspection API.

## Introspection API


## Meta API

### Context Predefined Types

Here is an exhaustive list of predefined types

```ruby :include
    require "checked_record/types"
    let(:predefined_types){CheckedRecord::Types.predefined}
```

```ruby :example They are kept in an Hash
  expect( predefined_types ).to be_kind_of(Hash)

  expect( predefined_types.keys ).to eq(
    %i[
      :alphanumeric,
      :float,
      :int,
      :name,
      :non_empty_alphanumeric, :non_empty_name,
      :non_empty_str, :non_negative_float, :non_negative_int, :non_negative_number,
      :number,
      :positive_float, :positive_int, :positive_number,
      :str, :sym
    ]
  ) 
```

Which can be accessed and tested

```ruby :include
    let(:alphanumeric) {predefined_types[:alphanumeric]}
    let(:non_empty_name) {predefined_types[:non_empty_name]}
    let(:sym) {predefined_types[:sym]}
```

How `:alphanumeric`  behaves:

```ruby :example Sample Type Checkers :alphanumeric
    expect( alphanumeric.("hello") ).to be_truthy
    expect( alphanumeric.("_hello_42") ).to be_truthy
    expect( alphanumeric.("42hello") ).to be_truthy
    expect( alphanumeric.("h%ello") ).to be_falsy
    expect( alphanumeric.("") ).to be_truthy
```

How `:non_empty_name`  behaves:

```ruby :example Sample Type Checkers :non_empty_name
    expect( non_empty_name.("hello") ).to be_truthy
    expect( non_empty_name.("_hello_42") ).to be_truthy
    expect( non_empty_name.("42hello") ).to be_falsy
    expect( non_empty_name.("h%ello") ).to be_falsy
    expect( non_empty_name.("") ).to be_falsy
```

How `:sym`  behaves:

```ruby :example Sample Type Checkers :sym
    expect( sym.(:hello) ).to be_truthy
    expect( sym.(:"adf\u2020e%zf") ).to be_truthy
    expect( sym.("hello") ).to be_falsy
    expect( sym.("") ).to be_falsy
```

### Context Type Constructors

These are defined in `CheckedRecord::Types` too

#### ConstrainedString

```ruby :include
    include CheckedRecord::Types
    let(:constrained_str) { constrained_str.(length: 2..4, match: %r{\A[a-z]*\z}) }
```

Wich ...

```ruby :example constrained_string
  expect( constrained_str ).to 
    
```


