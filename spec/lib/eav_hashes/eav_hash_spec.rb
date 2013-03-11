require 'spec_helper'

describe "EavHash/EavEntry" do
    # p[1-3] are defined in spec/dummy/db/seeds.rb and are used as fixtures
    let (:p1) { Product.find_by_name("Product 1") }
    let (:p2) { Product.find_by_name("Product 2") }
    let (:p3) { Product.find_by_name("Product 3") }

    it "deletes an EAV row when its value is set to nil" do
        p3_id = p3.id
        p3.tech_specs[:delete_me] = nil
        p3.save!

        p3_pulled = Product.find_by_id(p3_id)
        p3_pulled.tech_specs.keys.length.should == 0
    end

    it "is able to search for all models whose hashes contain a specified key" do
        Product.find_by_tech_specs("A String").length.should be == 2
        Product.find_by_tech_specs(:only_in_product_2).length.should be == 1
    end

    describe "distinguishes between string and symbol keys" do
        it "finds a value for symbol key \":symbolic_key\" in Product 1" do
            p1.tech_specs[:symbolic_key].should_not be_nil
        end

        it "does not find a value for non-symbol key \"symbolic_key\" in Product 1" do
            p1.tech_specs["symbolic_key"].should be_nil
        end
    end

    describe "preserves types between serialization and deserialization" do
        it "preserves String value types" do
            p1.tech_specs["A String"].should be_a_kind_of String
        end

        it "preserves Symbol value types" do
            p1.tech_specs["A Symbol"].should be_a_kind_of Symbol
        end

        it "preserves Integer/Bignum/Fixnum value types" do
            p1.tech_specs["A Number"].should be_a_kind_of Integer
        end

        it "preserves Symbol value types" do
            p1.tech_specs["A Float"].should be_a_kind_of Float
        end

        it "preserves Complex value types" do
            p1.tech_specs["A Complex"].should be_a_kind_of Complex
        end

        it "preserves Rational value types" do
            p1.tech_specs["A Rational"].should be_a_kind_of Rational
        end

        it "preserves Boolean(true) value types" do
            p1.tech_specs["True"].should be_a_kind_of TrueClass
        end

        it "preserves Boolean(false) value types" do
            p1.tech_specs["False"].should be_a_kind_of FalseClass
        end

        it "preserves Array value types" do
            p1.tech_specs["An Array"].should be_a_kind_of Array
        end

        it "preserves Hash value types" do
            p1.tech_specs["A Hash"].should be_a_kind_of Hash
        end

        it "preserves user-defined value types" do
            p1.tech_specs["An Object"].should be_a_kind_of CustomTestObject
        end
    end

    describe "preserves values between serialization and deserialization" do
        it "preserves String values" do
            p1.tech_specs["A String"].should be == "Strings are for cats!"
        end

        it "preserves Symbols" do
            p1.tech_specs["A Symbol"].should be == :symbol
        end

        it "preserves Integer/Bignum/Fixnum value types" do
            p1.tech_specs["A Number"].should be == 42
        end

        it "preserves Symbol values" do
            p1.tech_specs["A Float"].should be == 3.141592653589793
        end

        it "preserves Complex values" do
            p1.tech_specs["A Complex"].should be == Complex("3.141592653589793+42i")
        end

        it "preserves Rational values" do
            p1.tech_specs["A Rational"].should be == Rational(Math::PI)
        end

        it "preserves Boolean(true) values" do
            p1.tech_specs["True"].should be == true
        end

        it "preserves Boolean(false) values" do
            p1.tech_specs["False"].should be == false
        end

        it "preserves Array values" do
            p1.tech_specs["An Array"].should be == ["blue", 42, :flux_capacitor]
        end

        it "preserves Hash values" do
            p1.tech_specs["A Hash"].should be == {:foo => :bar}
        end

        it "preserves user-defined values" do
            p1.tech_specs["An Object"].test_value.should be == 42
        end
    end

    describe "cannot search by arrays, hashes, and objects" do
        it "raises an error when searched by an object" do
            lambda { Product.find_by_tech_specs("An Object", CustomTestObject.new(42)) }.should raise_error()
        end

        it "raises an error when searched by a hash" do
            lambda { Product.find_by_tech_specs("A Hash", {:foo => :bar}) }.should raise_error()
        end

        it "raises an error when searched by an array" do
            lambda { Product.find_by_tech_specs("An Array", ["blue", 42, :flux_capacitor]) }.should raise_error()
        end
    end
end