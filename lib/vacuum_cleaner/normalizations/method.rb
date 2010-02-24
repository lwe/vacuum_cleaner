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
      # Ensure access to default normalization method
      alias_method :default_normalize_value, :normalize_value
      
      # Helper method to "bake" a method normalizer from a method, enabling us to do stuff like.
      #
      #   TitelizeNormalizer = MethodNormalizer.build(:titleize)
      #
      def self.build(sym)
        module_eval "Class.new(MethodNormalizer) do; def initialize(*args); super({ :method => #{sym.inspect}}) end; end", __FILE__, __LINE__
      end
      
      # Accept either a hash or symbol name.
      def initialize(args = {})
        args = { :method => args } unless args.is_a?(Hash)
        super(args)
      end
      
      # Normalize value by calling the default normalizer (strip + nil if empty)
      # and then if not <tt>nil</tt> call the method defined.
      def normalize_value(value)
        sym = options[:method]
        value.respond_to?(sym) ? value.send(sym) : value
      end      
    end
    
    # Downcase value unless nil or empty.
    DowncaseNormalizer = MethodNormalizer.build(:downcase)
    
    # Upcases value unless nil or empty.
    UpcaseNormalizer = MethodNormalizer.build(:upcase)
  end
end