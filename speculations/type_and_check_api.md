
# Speculating about type and check API of `CheckedRecord` instances.

## Context  Immutable using Ruby's Types

Given

```ruby :include
    class Pet1 < CheckedRecord
      field :name, type: String
      field :age,  type: Integer
      field :species, type: Symbol
    end
```

We can constuct pets like these

```ruby :example Pets like these
    Pet1.new(name: "Rantanplan", age: 42, species: :dog)
    Pet1.new(name: "Garfield", age: 51, species: :cat)
```

And we are protected against things like...

```ruby :example Things like, well these

  expect{ Pet1.new(name: 42, age: 42, species: nil) }
    .to raise_error(CheckedRecord::ConstraintError)
```

However much nonsensical data is still accepted

```ruby :example Nonsensical but legal
  Pet1.new(name: "", age: -1, species: :zazefe)
```

## Better Types

`CheckedRecord` implements many useful built in types/checks, let us use some of
them in order to restrict the domain of our pets

```ruby :include
    require 'checked_record/types'
    class Pet2 < CheckedRecord
      field :name, type: NonEmptyName
      field :age, type: 0..100
      field :species, type: %i[cat dog]
    end
```

Now we can get some errors

```ruby :example quite some errors
  expected_error_message_match =
    %r{illegal value.*for field :name.*101.*for field :age.*"puppy".*for field :species}
  expect{ Pet2.new(name: "", age: 101, species: :puppy) }
    .to raise_error(CheckedRecord::ConstraintError, expected_error_message_match)
```

The predefined checkers can also be accessed with the Meta/Introspection API which is
demonstrated in this specualtion [Meta/Introspection API](./meta_introspection_api.md)  




