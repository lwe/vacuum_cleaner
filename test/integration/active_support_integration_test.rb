# encoding: utf-8
$KCODE = 'U' if RUBY_VERSION < '1.9'

require 'test_helper'

# run init.rb, which should load VacuumCleaner
require 'active_support'
require 'active_support/version'

require File.join(File.dirname(__FILE__), '..', '..', 'init')

puts "Running integration tests against: active_support-#{ActiveSupport::VERSION::STRING}"

class ActiveSupportIntegrationTest < ::Test::Unit::TestCase
  include VacuumCleaner::Normalizations
  
  context "VacuumCleaner::Normalizations::ActiveSupport" do
    context "TransliterateNormalizer" do
      should "call AS::Inflector#translitrate if value responds to to_str" do
        assert_equal "Geneve", TransliterateNormalizer.new.normalize_value("Genève")
        assert_equal "Zurich", TransliterateNormalizer.new.normalize_value("Zürich")
        assert_equal "Bern", TransliterateNormalizer.new.normalize_value("Bern")
        assert_equal "", TransliterateNormalizer.new.normalize_value("")
        assert_equal "\n ", TransliterateNormalizer.new.normalize_value("\n ")
        
        assert_nil TransliterateNormalizer.new.normalize_value(nil)
        assert_nil TransliterateNormalizer.new.normalize_value(12.5)
      end
    end
    
    context "TitleizeNormalizer" do
      should "call #titleize on string, else return nil" do
        assert_equal "My First Day", TitleizeNormalizer.new.normalize_value("my first day")
        assert_equal "My Mentor", TitleizeNormalizer.new.normalize_value("MY MENTOR")
        assert_nil TitleizeNormalizer.new.normalize_value(nil)
        assert_nil TitleizeNormalizer.new.normalize_value(42)
      end
    end
    
    context "HumanizeNormalizer" do
      should "call #humanize on string, else return nil" do
        assert_equal "My old lady", HumanizeNormalizer.new.normalize_value("My Old Lady")
        assert_equal "My two dads", HumanizeNormalizer.new.normalize_value("my two dads")
        assert_nil HumanizeNormalizer.new.normalize_value(nil)
        assert_nil HumanizeNormalizer.new.normalize_value(123.5)
      end
    end

    should "translitarte and upcase input value" do
      obj = Class.new { include VacuumCleaner::Normalizations; attr_reader :prefix; normalizes(:prefix, :upcase => true, :transliterate => true) }.new
      obj.prefix = "Genève\n\t"
      assert_equal "GENEVE", obj.prefix
    end
  end
end