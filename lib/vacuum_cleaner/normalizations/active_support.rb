# Okay, because about 99.9% of the usage is with Rails/AS, I guess it should
# have better/deeper support for it, like support for Multibyte stuff and some
# (useful) inflections.
#
# Please note that the +TransliterateNormalizer+ requires rails 3.0.0.beta3 and
# when run with ruby 1.9.
#
if defined?(::ActiveSupport)
  require 'active_support/inflector'
    
  require 'vacuum_cleaner/normalizations/method'  
  
  module VacuumCleaner
    module Normalizations      
      # Calls `ActiveSupport::Inflector.transliterate` if supplied
      # +value+ responds to +to_str+, so it basically only works on strings.
      class TransliterateNormalizer < Normalizer
        def normalize_value(value)
          ::ActiveSupport::Inflector.transliterate(value.to_str).to_s if value.respond_to?(:to_str)
        end
      end
          
      # Calls the `titleize` method from AS on the supplied value, if possible.
      TitleizeNormalizer = MethodNormalizer.build(:titleize)
    
      # Calls the `humanize` method from AS on the supplied value.
      HumanizeNormalizer = MethodNormalizer.build(:humanize)      
    end
  end

  # Set the multibyte proxy class to AS::Multibyte::Chars, which in turn works perfectly with UTF8 chars et al.
  VacuumCleaner::Normalizations::MethodNormalizer.multibyte_proxy_class = ::ActiveSupport::Multibyte::Chars
end