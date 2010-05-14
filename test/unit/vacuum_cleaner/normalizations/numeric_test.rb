require 'test_helper'
require 'vacuum_cleaner/normalizer'
require 'vacuum_cleaner/normalizations/numeric'

class VacuumCleaner::Normalizations::NumericTtest < Test::Unit::TestCase
  include VacuumCleaner::Normalizations
  
  context "NumericNormalizer#normalize_value" do
    should "remove any non numeric character, except decimal character" do
      assert_equal "10.5", NumericNormalizer.new.normalize_value("10.5")
      assert_equal "-12.3434", NumericNormalizer.new.normalize_value("-12.3434")      
      assert_equal "121250", NumericNormalizer.new.normalize_value("121'250 Mio. USD")
    end
    
    should "accept a negative prefix" do
      assert_equal "-450.00", NumericNormalizer.new.normalize_value("CHF -450.00")
      assert_equal "-.50", NumericNormalizer.new.normalize_value("- .50 SFr.")
    end
    
    should "strip single trailing points" do
      assert_equal "1250", NumericNormalizer.new.normalize_value("CHF 1250.--")      
    end
    
    should "work with German/Swiss notation of comma as decimal separator" do
      assert_equal "40.50", NumericNormalizer.new.normalize_value("CHF 40,50")
      assert_equal "1040.50", NumericNormalizer.new.normalize_value("EUR 1.040,50")
      assert_equal "-1100040.50", NumericNormalizer.new.normalize_value("EUR -1.100.040,50")
    end
    
    should "leave numeric and nil values as is" do
      assert_nil NumericNormalizer.new.normalize_value(nil)
      assert_equal 12.5, NumericNormalizer.new.normalize_value(12.5)
    end
  end  
end
