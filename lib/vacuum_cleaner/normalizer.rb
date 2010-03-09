module VacuumCleaner #:nodoc:
  
  # A small base class for implementing custom value normalizers.
  # Might seem like a slight overkill, yet makes the library pretty
  # reusable and all. Works like ActiveModel validators.
  #
  #   class TitleizeNormalizer < VacuumCleaner::Normalizer
  #     def normalize_value(value)
  #       value.titelize unless value.blank?
  #     end
  #   end
  #  
  #   class Person
  #     include VacuumCleaner::Normalizations
  #     normalizes :name, :titleize => true
  #   end
  #
  # Any class that inherits from +VacuumCleaner::Normalizer+ must implement
  # a method called <tt>normalize_value</tt> which accepts the <tt>value</tt> to normalize.
  # Furthermore the value returned by <tt>normalize_value</tt> is used as the new value for
  # the attribute.
  #
  # To reuse the behaviour as defined by the default normalizer (strip & empty),
  # just use <tt>super</tt>.
  #
  #   class MoreNilNormalizer < VacuumCleaner::Normalizer
  #     def normalize_value(value)
  #       value = super
  #       value = value.downcase if value.respond_to(:downcase)
  #       %w{0 nil null nul zero nix}.include?(value) ? nil : value
  #     end
  #   end
  #
  # If access to the record or attribute being normalized is required the method
  # +normalize+ can be overriden instead.
  #
  #    class FancyNormalizer < VacuumCleaner::Normalizer
  #      def normalize(object, attribute, value)
  #        ...
  #      end
  #    end
  #
  # When the normalization process is started for an attribute, the method
  # +normalize+ is called with the object, attribute and the value. The default
  # implementation of +normalize+ (as provided by this class) just calls
  # +normalize_value+.
  #
  # This can be used together with the +normalizes+ method (see
  # {{VacuumCleaner::Normalizers.normalizes}} for more on this).
  class Normalizer
    # Options as supplied to the normalizer.
    attr_reader :options
        
    # Accepts an array of options, which will be made available through the +options+ reader.
    def initialize(options = {})
      @options = options
    end
    
    # Only override this method if access to the <tt>object</tt> or <tt>attribute</tt> name
    # is required, else override +normalize_value+, makes life much simpler :)
    #
    # Default behaviour just calls <tt>normalize_value(value)</tt>.
    def normalize(object, attribute, value); normalize_value(value) end
    
    # Override this method in subclasses to specifiy custom normalization steps and magic.
    #
    # The standard implementation strips the value of trailing/leading whitespace and then
    # either returns that value or +nil+ if it's <tt>empty?</tt>.    
    def normalize_value(value)
      value = value.strip if value.respond_to?(:strip)
      value.nil? || (value.respond_to?(:empty?) && value.empty?) ? nil : value
    end
  end  
end