# CheckedRecord 

## Checking API

### General Check

A General Check is done by providing a block

```ruby :example a simple block 

  expect{ 
    Class.new(CheckedRecord) do
      field :a do |value|
        value != 'forbidden'
      end
    end.new(a: 'forbidden') }
    .to raise_error(CheckedRecord::ConstraintError, "illegal value \"forbidden\" for field :a")

```

A Lambda can also be used


```ruby :example checking with a λ

  not_the_answer = ->(value) { value != 42}
  expect{ 
    Class.new(CheckedRecord) do
      field :a, check: not_the_answer
    end.new(a: 42) }
    .to raise_error(CheckedRecord::ConstraintError, "illegal value 42 for field :a")

```

### Predefined Lambdas

When the `check` parameter is provided with a symbol the symbol is interpreted as
a predefined checking lambda:

The following speculation uses an undefined symbol and the error message shows all predefined lambdas

```ruby :include
    let(:predefined_list) {
      [
        ":int", 
        ":non_negative_int", 
        ":positive_int",
        ":string, :sym"
      ].join("\n            ")
    }
```


```ruby :example Oh no, but show...

  expect{ 
    Class.new(CheckedRecord) do
      field :a, check: :no_such_predefined_checker
    end
  }
  .to raise_error(ArgumentError, "undefined check :no_such_predefined_checker\npredefined: #{predefined_list}")
    
```

By using and violating these predefined checks we can get quite an error list

```ruby :include
    class AllPredefined < CheckedRecord
      field :z, check: :int
      field :p, check: :positive_int
      field :n, check: :non_negative_int
      field :name, check: :string
      field :id, check: :sym
    end
```

```ruby :example What an error message
  expected_message = [
    %{illegal value 42.0 for field :z},
    %{illegal value 0 for field :p},
    %{illegal value -1 for field :n},
    %{illegal value :me for field :name},
    %{illegal value "hello" for field :id}
  ].join("\n")

  expect{ 
    AllPredefined.new(
    z: 42.0,
    p: 0,
    n: -1,
    name: :me,
    id: "hello"
    )
  }
    .to raise_error(CheckedRecord::ConstraintError, expected_message)
    
```


