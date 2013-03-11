eav_hashes
=========

[![Code Climate](https://codeclimate.com/badge.png)](https://codeclimate.com/github/200proof/eav_hashes) [![Build Status](https://travis-ci.org/200proof/eav_hashes.png?branch=master)](https://travis-ci.org/200proof/eav_hashes)

`eav_hashes` is a neato gem for implementing the EAV (entity-attribute-value)
database design pattern in your Rails models. All you need to do is add one
line to your model's code and that's it! Schema generation is automatically
handled for you.

Why would I need it?
-
Rails' ActiveRecord includes a helper function, `serialize`, to allow you to
save complex data types (like hashes) into your database. Unfortunately, it
isn't very useful. A lot of overhead is created from serialization and
deserialization, and you can't search by the contents of your hash. That's
where `eav_hashes` comes in.

How does it work?
-
Great question! Lets dive in with a simple code example:

```ruby
class Product < ActiveRecord::Base
    eav_hash_for :tech_specs
end
```

Now run this generator to create a migration:

    $ rails generate eav_migration Product tech_specs

And run the migration:

    $ rake db:migrate

Now watch the magic the happen:

```ruby
# Assuming this whole example is on a blank DB, of course
a_product = Product.new
a_product.tech_specs["Widget Power"] = "1.21 GW"
a_product.tech_specs["Battery Life (hours)"] = 12
a_product.tech_specs["Warranty (years)"] = 3.5
a_product.tech_specs["RoHS Compliant"] = true
a_product.save!

# Setting a value to nil deletes the entry
a_product.tech_specs["Warranty (years)"] = nil
a_product.save!

the_same_product = Product.first
puts the_same_product.tech_specs["nonexistant key"]

# magic alert: this actually gets the count of EVERY entry of every
# hash for this model, but for this example this works
puts "Entry Count: #{ProductTechSpecsEntry.count}"
the_same_product.tech_specs.each_pair do |key, value|
    puts "#{key}: #{value.to_s}"
end

# Ruby's default types: Integer, Float, Complex, Rational, Symbol,
# TrueClass, and FalseClass are preserved between transactions like
# you would expect them to.
puts the_same_product.tech_specs["Battery Life (hours)"]+3
```

And the output, as you can expect, will be along the lines of:

    nil
    Entry Count: 3
    Widget Power: 1.21 GW
    Battery Life (hours): 12
    RoHS Compliant: true
    15


That looks incredibly simple, right? Good! It's supposed to be! All the magic
happens when you call `save!`.

Now you could start doing other cool stuff, like searching for products based
on their tech specs! You've already figured out how to do this, haven't you?

```ruby
flux_capacitor = Product.find_by_tech_specs("Widget Power", "1.21 GW")
```

Nifty, right?

Can I store arrays/hashes/custom types inside my hashes?
--
Sure, but they'll be serialized into YAML (so you cant search by them like you
would an eav_hash). The `value` column is a TEXT type by default but if you
want to optimize your DB size you could change it to a VARCHAR in the migration
if you don't plan on storing large values.


What if I want to change the table name?
--
By default, `eav_hash` uses a table name derived from the following:

```ruby
"<ClassName>_<hash_name>".tableize
```

You can change this by passing a symbol to the `:table_name` argument:

```ruby
class Widget < ActiveRecord::Base
    eav_hash_for :foobar, table_name: :bar_foo
end
```

Just remember to edit the table name in the migration, or use the following
migration generator:

    $ rails generate eav_migration Widget foobar bar_foo


What's the catch?
-
By using this software, you agree to write me into your will as your next of
kin, and to sacrifice the soul of your first born child to Beelzebub.

Just kidding, the code is released under the MIT license so you can use it for
whatever purposes you see fit. Just don't sue me if your application blows up
from the sheer awesomeness! Check out the LICENSE file for more information.

Special Thanks!
-
Thanks to [Matt Kimmel](https://github.com/mattkimmel) for adding support for models contained in namespaces.

I found a bug or want to contribute!
-
You're probably reading this from GitHub, so you know what to do. If not, the
Github project is at https://github.com/200proof/eav_hashes
