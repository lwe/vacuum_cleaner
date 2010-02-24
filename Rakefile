require 'rake'
require 'rake/testtask'
require 'yard'
require File.join(File.dirname(__FILE__), 'lib', 'vacuum_cleaner')

desc 'Test the vacuum_cleaner plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for vacuum_cleaner. (requires yard)'
YARD::Rake::YardocTask.new(:doc) do |t|
  t.files = ['lib/**/*.rb']
  t.options = [
      "--readme", "README.md",
      "--title", "vacuum_cleaner (v#{VacuumCleaner::VERSION}) API Documentation"
  ]
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "vacuum_cleaner"
    gemspec.version = VacuumCleaner::VERSION
    gemspec.summary = "Ruby (and Rails) attribute cleaning support, provides some nice default normalization strategies."
    description = <<-DESC
      ** Swoooosh ** - and all those leading and trailing whitespaces are gone, or ** Frooom ** - and the value
      is normalized to always be prefixed by 'http://' and much more. Works with both plain old Ruby, and Rails (ActiveModel
      and ActiveSupport).
    DESC
    gemspec.description = description.strip
    gemspec.email = "lukas.westermann@gmail.com"
    gemspec.homepage = "http://github.com/lwe/vacuum_cleaner"
    gemspec.authors = ["Lukas Westermann"]
    gemspec.licenses = %w{LICENSE}
    gemspec.extra_rdoc_files = %w{README.md}
    
    gemspec.add_development_dependency('shoulda', '>= 2.10.2')
    gemspec.add_development_dependency('rr', '>= 0.10.5')
    # gemspec.add_development_dependency('activesupport', '>= 2.3.5')
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler, or one of its dependencies, is not available. Install it with: sudo gem install jeweler"
end

desc 'Clean all generated files (.yardoc and doc/*)'
task :clean do |t|
  FileUtils.rm_rf "doc"
  FileUtils.rm_rf "pkg"
  FileUtils.rm_rf ".yardoc"
end

namespace :metrics do
  desc 'Report all metrics, i.e. stats and code coverage.'
  task :all => [:stats, :coverage]
  
  desc 'Report code statistics for library and tests to shell.'
  task :stats do |t|
    require 'code_statistics'
    dirs = {
      'Libraries' => 'lib',
      'Unit tests' => 'test/unit'
    }.map { |name,dir| [name, File.join(File.dirname(__FILE__), dir)] }
    CodeStatistics.new(*dirs).to_s
  end
  
  desc 'Report code coverage to HTML (doc/coverage) and shell (requires rcov).'
  task :coverage do |t|
    rm_f "doc/coverage"
    mkdir_p "doc/coverage"
    rcov = %(rcov -Ilib:test --exclude '\/gems\/' -o doc/coverage -T test/unit/vacuum_cleaner/*_test.rb -T test/unit/vacuum_cleaner/*/*_test.rb)
    system rcov
  end
  
  desc 'Report the fishy smell of bad code (requires reek)'
  task :smelly do |t|
    puts
    puts "* * * NOTE: reek currently reports several false positives,"
    puts "      eventhough it's probably good to check once in a while!"
    puts
    reek = %(reek -s lib)
    system reek
  end
end
