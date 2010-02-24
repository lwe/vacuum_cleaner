require 'vacuum_cleaner'

ActiveRecord::Base.class_eval { include VacuumCleaner::Normalizations } # all versions of rails
# ActiveModel::Base.class_eval { include VacuumCleaner::Normalizations } if defined?(ActiveModel::Base) # Rails 3+