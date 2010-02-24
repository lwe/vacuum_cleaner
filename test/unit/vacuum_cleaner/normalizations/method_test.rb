require 'test_helper'
require 'vacuum_cleaner/normalizer'
require 'vacuum_cleaner/normalizations/method'

class VacuumCleaner::Normalizations::MethodNormalizerTest < Test::Unit::TestCase
  include VacuumCleaner::Normalizations
  
  context "MethodNormalizer" do
    should "accept method name as initialization argument" do
      downcaser = MethodNormalizer.new(:downcase)
      assert_equal "elliot\n", downcaser.normalize_value("Elliot\n")
      assert_equal "  \t", downcaser.normalize_value("  \t")
    end
    
    should "accept hash with :method key as initializer" do
      upcaser = MethodNormalizer.new(:method => :upcase)
      assert_equal "ELLIOT\n", upcaser.normalize_value("Elliot\n")
      assert_equal "  \t", upcaser.normalize_value("  \t")      
    end
  end
    
  context "DowncaseNormalizer#normalize_value" do
    should "downcase input" do
      assert_equal "elliot", DowncaseNormalizer.new.normalize_value("Elliot")
    end
  end
  
  context "UpcaseNormalizer#normalize_value" do
    should "upcase input" do
      assert_equal "J.D.", UpcaseNormalizer.new.normalize_value("j.d.")
    end
  end
end