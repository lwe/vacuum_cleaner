require 'rubygems'
require 'bundler/setup'
require 'rake/testtask'

task :default => :'test:all'

namespace :test do
  desc 'Test the vacuum_cleaner plugin.'
  Rake::TestTask.new(:unit) do |t|
    t.libs << 'test'
    t.pattern = 'test/unit/**/*_test.rb'
    t.verbose = true
  end

  desc 'Run integration tests for the vacuum_cleaner plugin.'
  Rake::TestTask.new(:integration) do |t|
    t.libs << 'test'
    t.pattern = 'test/integration/**/*_test.rb'
    t.verbose = true
  end

  desc 'Run both the integration and unit tests'
  task :all => [:'test:unit', :'test:integration']
end
