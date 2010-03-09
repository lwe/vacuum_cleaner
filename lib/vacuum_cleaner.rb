# Fancy value normalization utility for ruby (and rails).
module VacuumCleaner
  # +VacuumCleaner+ version string, current version is 0.1.0.
  VERSION = "0.5.0".freeze
  
  autoload :Normalizer, 'vacuum_cleaner/normalizer'
  autoload :Normalizations, 'vacuum_cleaner/normalizations'
end