require 'rubygems'
require 'bundler/setup'
require 'test/unit'
require 'shoulda'

# load redgreen, if available
begin; require 'redgreen'; rescue LoadError; end
