# Fancy value normalization utility for ruby (and rails),
# see {VacuumCleaner::Normalizations} for more information about usage.
#

require 'vacuum_cleaner/normalizer'
require 'vacuum_cleaner/normalizations'

# @see VacuumCleaner::Normalizations
# @see VacuumCleaner::Normalizer
module VacuumCleaner
  # +VacuumCleaner+ version
  VERSION = "1.0.1".freeze
end

if defined?(ActiveSupport) && ActiveSupport.respond_to?(:on_load)
  ActiveSupport.on_load(:active_record) { include VacuumCleaner::Normalizations }
else
  ActiveRecord::Base.send(:include, VacuumCleaner::Normalizations) if defined?(ActiveRecord)  
end
