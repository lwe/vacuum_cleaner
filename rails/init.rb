require 'vacuum_cleaner'

ActiveRecord::Base.class_eval { include VacuumCleaner::Normalizations } if defined?(ActiveRecord::Base) # all versions of rails