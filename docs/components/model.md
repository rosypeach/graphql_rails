# Model

To make your model graphql-firendly, you need to inlcude `GraphqlRails::Model`. Your model can be any ruby class (PORO, ActiveRecord::Base or anything else)

Also you need to define which attributes can be exposed via graphql. To do so, use `graphql` method inside your model body. Example:

```ruby
class User # works with any class including ActiveRecord
  include GraphqlRails::Model

  graphql do |c|
    c.attribute :id
    c.full_name, type: :string
  end
end
```

## _graphql_

This method must be called inside your model body. `grapqhl` is used for making your model convertible to graphql type.

### _attribute_

Most commonly you will use `attribute` to make your model methods and attributes visible via graphql endpoint.

#### _type_

Some types can be determined by attribute name, so you can skip this attribute:

* attributes which ends with name `*_id` has `ID` type
* attributes which ends with `?` has `Boolean` type
* all other attributes without type are considered to be `String`

available types are:

* ID: `'id'`
* String: `'string'`, `'str'`, `'text'`
* Boolean: `'bool'`, `'boolean'`
* Float: `'float'`, `'double'`, `'decimal'`

usage example:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute :shop_id # ID type
    c.attribute :full_name # String type
    c.attribute :admin? # Boolean type
    c.attribute :level, type: 'integer'
    c.attribute :money, type: 'float'
  end
end
```

#### _property_

By default graphql attribute names are expected to be same as model methods/attributes, but if you want to use different name on grapqhl side, you can use `propery` option:

```
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute :shop_id, property: :department_id
  end

  def department_id
    456
  end
end
```

#### _description_

You can also describe each attribute and make graphql documentation even more readable. To do so, add `description` option:

```
class User
  include GraphqlRails::Model

  graphql do |c|
    c.attribute :shop_id, description: 'references to shop'
  end
end
```

### _name_

By default grapqhl type name will be same as model name, but you can change it via `name` method

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.name 'Employee'
  end
end
```

### _description_

To improve grapqhl documentation, you can description for your graphql type:

```ruby
class User
  include GraphqlRails::Model

  graphql do |c|
    c.description 'Users are awesome!'
  end
end
```

### *graphql_type*

Sometimes it's handy to get raw graphql type. To do so you can call:

```ruby
YourModel.graphql.grapqhl_type
```
