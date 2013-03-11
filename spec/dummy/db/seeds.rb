p = Product.new
p.name = "Product 1"
p.tech_specs << {
  "A Complex"   => Complex("3.141592653589793+42i"),
  "A Float"     => 3.141592653589793,
  "A Number"    => 42,
  "A Rational"  => Rational(Math::PI),
  "A Symbol"    => :symbol,
  "A String"    => "Strings are for cats!",
  "An Array"    => ["blue", 42, :flux_capacitor],
  "A Hash"      => {:foo => :bar},
  "An Object"   => CustomTestObject.new(42),
  "False"       => false,
  "True"        => true,
  :symbolic_key => "This key is SYMBOLIC!!!!!1!!"
}

p2 = Product.new

p2.name = "Product 2"
(p2.tech_specs << p.tech_specs) << { :only_in_product_2 => :mustard_pimp }

p3 = Product.new
p3.name = "Product 3"
p3.tech_specs[:delete_me] = "set me to nil in the tests, save the model, pull it again and ensure p3.tech_specs.keys.length == 0"

p.save
p2.save
p3.save

puts "Seeded the database."