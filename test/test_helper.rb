require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'rr'

# require 'normalo'

Test::Unit::TestCase.send(:include, RR::Adapters::TestUnit)

# Dir[File.dirname(__FILE__) + "/fixtures/*.rb"].each { |fixture| require fixture }