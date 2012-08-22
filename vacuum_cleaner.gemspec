# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "vacuum_cleaner/version"

Gem::Specification.new do |s|
  s.name        = "vacuum_cleaner"
  s.version     = VacuumCleaner::VERSION
  s.platform    = Gem::Platform::RUBY
  s.summary     = "Simple attribute normalization support."
  s.description = "Ruby (and Rails) attribute cleaning support, provides some nice and easy to enhance default normalization strategies."

  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.6"

  s.authors  = ["Lukas Westermann"]
  s.email    = ["lukas.westermann@gmail.com"]
  s.homepage = "http://github.com/lwe/vacuum_cleaner"

  s.files            = `git ls-files`.split("\n")
  s.test_files       = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path     = 'lib'

  s.license          = 'MIT'

  s.add_development_dependency 'rake', '>= 0.9.2'
  s.add_development_dependency 'shoulda', '>= 2.10'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'activesupport', '>= 3.2.0'
  s.add_development_dependency 'activerecord', '>= 3.2.0'
end

