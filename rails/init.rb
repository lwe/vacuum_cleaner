require 'vacuum_cleaner'

ActiveRecord::Base.class_eval { include VacuumCleaner::Normalizations } # all versions of rails