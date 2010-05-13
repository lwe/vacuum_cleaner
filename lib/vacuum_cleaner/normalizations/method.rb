module VacuumCleaner
  module Normalizations
    
    # Generic method based normalizer which just calls supplied method
    # on value (unless nil).
    #
    #   normalizes :name, :method => :titelize
    #
    # Custom instances accept a <tt>:method</tt> option.
    #
    #   MethodNormalizer.new(:method => :titelize)
    #
    # Subclasses of the +MethodNormalizer+ can take advantage of it's
    # +normalize_if_respond_to+ method, to easily create custom
    # normalizers based on methods availble on the result value.
    class MethodNormalizer < Normalizer
      
      class << self  
        # Helper method to "bake" a method normalizer from a method, enabling us to do stuff like.
        #
        #   TitelizeNormalizer = MethodNormalizer.build(:titleize)
        #
        def build(sym)
          module_eval "Class.new(MethodNormalizer) do; def initialize(*args); super({ :method => #{sym.inspect}}) end; end", __FILE__, __LINE__
        end
        
        # Due to the lack of multibyte support in ruby core, a proxy class like
        # {ActiveSupport::Multibyte::Chars} can be registered here and the proxy
        # is then used to wrap string values within, so that methods like `upcase`
        # or `downcase` work with characters outside the ASCII range as well.
        #
        # The wrapper is only used if the value supplied is a string, i.e. responds to
        # +to_str+.
        def multibyte_wrapper=(clazz); @multibyte_wrapper = clazz end        
        def multibyte_wrapper; @multibyte_wrapper end
      end
      
      # Accept either a hash or symbol name.
      def initialize(args = {})
        args = { :method => args } unless args.is_a?(Hash)
        super(args)
      end
            
      # Normalize value by trying to call the method at hand, if
      # +value+ does not respond to the defined method, returns +nil+.
      def normalize_value(value)
        sym = options[:method]
        value = MethodNormalizer.multibyte_wrapper.new(value) if MethodNormalizer.multibyte_wrapper and value.respond_to?(:to_str)
        value.respond_to?(sym) ? value.send(sym) : nil
      end      
    end
    
    # Downcase value unless nil or empty.
    DowncaseNormalizer = MethodNormalizer.build(:downcase)
  
    # Upcases value unless nil or empty.
    UpcaseNormalizer = MethodNormalizer.build(:upcase)
  end
end