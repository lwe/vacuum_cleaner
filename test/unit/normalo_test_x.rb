require 'test_helper'

class NormaloTest < Test::Unit::TestCase
  context "`extend Normalo`" do
    should "provide #normalize to anonymous class" do
      assert_respond_to Class.new { extend Normalo::Normalizer }, :normalize
    end
  end
  
  context "#normalize" do
    should "take a symbol as argument" do
      assert_respond_to Class.new { extend Normalo::Normalizer; normalize(:name) }, :normalize
    end
    
    should "take multiple symbols as argument" do
      klass = Class.new { extend Normalo::Normalizer; normalize(:name, :first_name) }
      assert_respond_to klass, :normalize
      assert_respond_to klass, :normalize_name
      assert_respond_to klass, :normalize_first_name
    end
    
    should "create a setter for supplied attribute" do
      obj = Class.new { extend Normalo::Normalizer; normalize(:name) }.new
      assert_respond_to obj, :name=
    end
    
    should "set the instance variable using the setter" do
      obj = Class.new { extend Normalo::Normalizer; normalize(:name) }.new
      obj.name = "J.D."
      assert_equal "J.D.", obj.instance_variable_get(:@name)
    end
    
    should "alias method to <attr>_without_normalization= if <attr>= already defined" do
      klass = Class.new do
        extend Normalo::Normalizer
        def name=(name); @foo = name end
        normalize :name
      end
      obj = klass.new
      obj.name = "Elliot Reid"
      assert_respond_to obj, :name_without_normalization=
      assert_equal "Elliot Reid", obj.instance_variable_get(:@foo)
      assert_nil obj.instance_variable_get(:@name)
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
        extend Normalo::Normalizer
        attr_accessor :name
        normalize :name do |value|
          value = value.to_nil_if_empty
          value ? value.upcase : value
        end
      end
      obj = klass.new
      obj.name = "Turk"
      assert_equal "TURK", obj.name
    end
  end
end