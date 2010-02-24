require 'test_helper'
require 'vacuum_cleaner/normalizer'

class VacuumCleaner::NormalizerTest < Test::Unit::TestCase
  context "VacuumCleaner::Normalizer" do
    should "take an optional hash as argument during #initialize and expose that hash when calling #options" do
      expected = { :doctor => "Dr. Dorian", :nurse => "Carla" }
      normalizer = VacuumCleaner::Normalizer.new({ :doctor => "Dr. Dorian", :nurse => "Carla" })
      assert_equal "Dr. Dorian", normalizer.options[:doctor]
      assert_equal expected, normalizer.options
    end
    
    context "#normalize_value" do
      should "leave <nil>" do
        assert_nil VacuumCleaner::Normalizer.new.normalize_value(nil)
      end
      
      should "convert empty string to <nil>" do
        assert_nil VacuumCleaner::Normalizer.new.normalize_value('')
      end
      
      should "convert string with only space characters to <nil>" do
        assert_nil VacuumCleaner::Normalizer.new.normalize_value(" ")
        assert_nil VacuumCleaner::Normalizer.new.normalize_value(" \n\t ")        
      end
      
      should "strip leading and trailing whitespace" do
        assert_equal "Dr. Reid", VacuumCleaner::Normalizer.new.normalize_value(" \nDr. Reid\t ")
        assert_equal "Dr. Dorian", VacuumCleaner::Normalizer.new.normalize_value("Dr. Dorian\t \r")
      end
    end
    
    context "#normalize" do
      should "return always the same as #normalize_value and ignore object and attribute parameters" do
        normalizer = VacuumCleaner::Normalizer.new
        object = Object.new
        attribute = :name
        
        [["Dr. Reid", "\t Dr. Reid"], ["Dr. Dorian", "Dr. Dorian\n "], [nil, nil], [nil, "\n "], [nil, ""]].each do |tests|
          expected, value = *tests
          assert_equal expected, normalizer.normalize_value(value)
          assert_equal expected, normalizer.normalize(object, attribute, value)
        end
      end
    end
  end
end
