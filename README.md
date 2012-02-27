Chronicle
=========

Chronicle groups collections of ActiveRecord objects into chronologically ordered hashes.
It uses [Chronic](https://github.com/mojombo/chronic/) to parse natural language dates 
and [ActiveSupport::OrderedHash](http://apidock.com/rails/ActiveSupport/OrderedHash)
to keep buckets in a predictable order.

```ruby
# Before...
[
  object_1,
  object_2,
  object_3,
  object_4,
  object_5,
  object_6,
  object_7,
  object_8
]

# After... 
{
  "just now": [object_10, object_9],
  "two hours ago": [object_8, object_7, object_6],
  "yesterday": [object_5, object_4, object_3],
  "6 months ago": [object_2],
  "1 year ago": [object_1]
}
```

Installation
------------

```ruby
# Put this in your Gemfile and smoke it.
gem 'chronicle'
```

Usage
-----

```ruby
# Fetch some objects (presumably ActiveRecord)
things = Thing.all

# Put them into buckets, using Chronicle's default eras
chronicle = Chronicle.new(things)

# To deviate from the default eras...
chronicle = Chronicle.new(things, :eras => ["5 minutes ago", 2 hours ago", "three weeks ago"])

# To sort based on an attribute other than :created_at
chronicle = Chronicle.new(things, :date_attr => :updated_at)
```

License
-------

MIT License. Do whatever you want.