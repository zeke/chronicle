Chronicle
=========

Chronicle groups collections of ruby objects into time periods.
It uses [Chronic](https://github.com/mojombo/chronic/) to parse natural language date strings
and [ActiveSupport::OrderedHash](http://apidock.com/rails/ActiveSupport/OrderedHash)
to preserve the hash order.

```ruby
# Before:
[obj_1, obj_2, obj_3, obj_4, obj_5, obj_6, obj_7, obj_8, obj_9, obj_10]

# After:
{
  "just now": [obj_10, obj_9],
  "two hours ago": [obj_8, obj_7, obj_6],
  "yesterday": [obj_5, obj_4, obj_3],
  "6 months ago": [obj_2],
  "1 year ago": [obj_1]
}
```

An example UI using Chronicle:

[ !["Chronicle on Sniphr"](http://f.cl.ly/items/2I2q0P0w2Z2r0D0d390D/chronicle.png "Chronicle on Sniphr") ](http://sniphr.com "Sniphr")

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
chronicle = Chronicle.new(things, :eras => ["5 minutes ago", "2 hours ago", "three weeks ago"])

# To sort based on an attribute other than :created_at
chronicle = Chronicle.new(things, :date_attr => :updated_at)
```

To see the default `eras` used by Chronicle, have a look at 
[chronicle.rb](https://github.com/zeke/chronicle/blob/master/lib/chronicle.rb#L16).

License
-------

MIT License. Do whatever you want.