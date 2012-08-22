# Fancy value normalization utility for ruby (and rails),
# see {VacuumCleaner::Normalizations} for more information about usage.
#

# @see VacuumCleaner::Normalizations
# @see VacuumCleaner::Normalizer
module VacuumCleaner
  autoload :VERSION, 'vacuum_cleaner/version'

  autoload :Normalizer, 'vacuum_cleaner/normalizer'
  autoload :Normalizations, 'vacuum_cleaner/normalizations'
end

if defined?(ActiveSupport) && ActiveSupport.respond_to?(:on_load)
  ActiveSupport.on_load(:active_record) { include VacuumCleaner::Normalizations }
end
