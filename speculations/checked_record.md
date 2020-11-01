# CheckedRecord

A `Struct` like superclass with constraints (writeable, types, runtime constraints, optional immutability)
Like a record but with type/constraint checks

```ruby :include
    require "checked_record"
    class Animal < CheckedRecord
      field :species, enum: [:dog, :cat], default: :dog
      field :sex, enum: [:male, :female]
      field :breed, type: String 
      field :age, type: Integer, assert: -> {_1 > 0} 
    end
```

## Object Nursery

Let's begin with a legal `Animal` 

```ruby :example A default dog
  vilma = Animal.new(sex: :female, breed: "Labrador", age: 16)
    
```









