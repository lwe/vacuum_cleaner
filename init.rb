require 'vacuum_cleaner'

if Object.const_defined?("ActiveRecord")
  ActiveRecord::Base.send(:include, VacuumCleaner::Normalizations)
end
