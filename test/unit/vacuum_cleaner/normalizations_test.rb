require 'test_helper'

require 'vacuum_cleaner/normalizer'
require 'vacuum_cleaner/normalizations'

class PrefixDoctorNormalizer < VacuumCleaner::Normalizer
  def normalize_value(value)
    "Dr. #{value}"
  end
end

class Person
  include VacuumCleaner::Normalizations
  
  attr_accessor :last_name, :first_name
  
  normalizes :last_name
  normalizes :first_name
end

class Doctor
  include VacuumCleaner::Normalizations
  attr_accessor :name
  
  class GirlifyNormalizer < VacuumCleaner::Normalizer
    def normalize_value(value)
      value == "J.D." ? "Maria" : value
    end
  end          
  
  normalizes :name, :girlify => true          
end

class VacuumCleaner::NormalizationsTest < Test::Unit::TestCase
  context "VacuumCleaner::Normalizations" do
    context "ClassMethods#normalizes" do
      should "throw ArgumentError if no attributes are passed in" do
        assert_raise ArgumentError do
          klass = Class.new { include VacuumCleaner::Normalizations; normalizes }
        end        
      end
      
      should "throw ArgumentError if invalid/unknown normalizer is used" do
        assert_raise ArgumentError do
          klass = Class.new { include VacuumCleaner::Normalizations; normalizes(:name, :foobar_unkown_normalizer => true) }
        end
      end        
       
      should "take a symbol as argument" do
        assert_respond_to Class.new { include VacuumCleaner::Normalizations; normalizes(:name) }, :normalizes
      end

      should "take multiple symbols as argument" do
        klass = Class.new { include VacuumCleaner::Normalizations; normalizes(:name, :first_name) }
        assert_respond_to klass, :normalizes
      end

      should "create a setter for supplied attribute" do
        obj = Class.new { include VacuumCleaner::Normalizations; normalizes(:name) }.new
        assert_respond_to obj, :name=
        assert_respond_to obj, :normalize_name
      end

      should "set the instance variable using the setter" do
        obj = Class.new { include VacuumCleaner::Normalizations; attr_reader :name; normalizes(:name) }.new
        obj.name = "J.D."
        assert_equal "J.D.", obj.name
      end
      
      should "alias method to <attr>_without_normalization= if <attr>= already defined" do
        klass = Class.new do
          include VacuumCleaner::Normalizations
          attr_reader :name, :foo
          def name=(name); @foo = name end
          normalizes :name
        end
        obj = klass.new
        obj.name = "Elliot Reid"
        assert_respond_to obj, :name_without_normalization=
        assert_equal "Elliot Reid", obj.foo
        assert_nil obj.name
      end

      should "convert any blank input, like empty string, nil etc. to => <nil>" do
        obj = Person.new
        obj.first_name = " "
        obj.last_name = ''
        assert_nil obj.first_name
        assert_nil obj.last_name
      end
      
      should "strip leading and trailing white-space" do
        obj = Person.new
        obj.first_name = "\nElliot\t "
        obj.last_name = nil
        assert_nil obj.last_name
        assert_equal "Elliot", obj.first_name
      end

      should "accept a block which overrides the default to_nil_if_empty strategy" do
        klass = Class.new do
          include VacuumCleaner::Normalizations
          attr_accessor :name
          normalizes :name do |value|
            value ? value.upcase : value
          end
        end
        obj = klass.new
        obj.name = "Turk"
        assert_equal "TURK", obj.name
      end
      
      should "accept custom options hash to define other normalizers to run" do
        klass = Class.new do
          include VacuumCleaner::Normalizations
          attr_accessor :email
          normalizes :email, :downcase => true
        end
        obj = klass.new
        obj.email = "\nJ.D.Dorian@Sacred-Heart.com "
        assert_equal "j.d.dorian@sacred-heart.com", obj.email
      end
      
      should "raise ArgumentError if invalid/unknown normalizer is called" do
        assert_raise ArgumentError do
          Class.new do
            include VacuumCleaner::Normalizations
            normalizes :foo, :invalid_unknown_normalizer => true
          end
        end
      end
      
      should "ignore default split/empty? normalizer if :default => false" do
        klass = Class.new do
          include VacuumCleaner::Normalizations
          attr_accessor :name
          normalizes :name, :default => false, :upcase => true
        end
        obj = klass.new
        obj.name = "Dr. Dorian\n\t"
        assert_equal "DR. DORIAN\n\t", obj.name
      end
      
      should "be able to use normalizers from the global namespace" do
        klass = Class.new do
          include VacuumCleaner::Normalizations
          attr_accessor :name
          normalizes :name, :prefix_doctor => true
        end
        obj = klass.new
        obj.name = "Elliot Reid"
        assert_equal "Dr. Elliot Reid", obj.name
      end
      
      should "be able to use normalizers from within the class itself" do
        obj = Doctor.new
        obj.name = "Elliot Reid"
        assert_equal "Elliot Reid", obj.name
        obj = Doctor.new
        obj.name = "J.D."
        assert_equal "Maria", obj.name
      end
      
      should "be able to combine normalizers and custom blocks" do
        klass = Class.new do
          include VacuumCleaner::Normalizations
          attr_accessor :name, :first_name
          normalizes(:name, :first_name, :downcase => true) do |value|
            value.nil? ? value : "#{value.to_s[0,1].upcase}#{value.to_s[1..-1]}"
          end
        end
        
        obj = klass.new
        obj.name = "REID"
        obj.first_name = "ELLIOT"
        assert_equal "Reid", obj.name
        assert_equal "Elliot", obj.first_name
      end
      
      should "provide block with all values if asking for them!" do
        klass = Class.new do
          include VacuumCleaner::Normalizations
          attr_accessor :name
          normalizes(:name) do |object, attribute, value|
            [object.object_id, attribute, value]
          end
        end
        
        obj = klass.new
        obj.name = "Carla"
        assert_equal [obj.object_id, :name, "Carla"], obj.name
      end
    end
  end
end