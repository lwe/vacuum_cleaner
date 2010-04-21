# Fancy value normalization utility for ruby (and rails),
# see {VacuumCleaner::Normalizations} for more information about usage.
#
# @see VacuumCleaner::Normalizations
# @see VacuumCleaner::Normalizer
module VacuumCleaner
  # +VacuumCleaner+ version
  VERSION = "1.0.0".freeze
  
  autoload :Normalizer, 'vacuum_cleaner/normalizer'
  autoload :Normalizations, 'vacuum_cleaner/normalizations'
end