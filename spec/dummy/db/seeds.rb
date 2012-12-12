p = Product.new
p.name = "Product 1"
p.tech_specs << {
  "A Complex"   => Complex("3.141592653589793+42i"),
  "A Float"     => 3.141592653589793,
  "A Number"    => 42,
  "A Rational"  => Rational(Math::PI),
  "A Symbol"    => :symbol,
  "False"       => false,
  "True"        => true,
  :symbolic_key =>"This key is SYMBOLIC!!!!!1!!"
}

p2 = Product.new
p2.name = "Product 2"
(p2.tech_specs << p.tech_specs) << { :only_in_product_2 => :mustard_pimp }

p.save
p2.save