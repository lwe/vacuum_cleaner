module VacuumCleaner
  module Normalizations
    WITHOUT_NORMALIZATION_SUFFIX = "_without_normalization"
    
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    module ClassMethods
      def normalizes(*attributes, &block)
        metaklass = class << self; self; end
        
        normalizations = attributes.last.is_a?(Hash) ? attributes.pop : {}
        raise ArgumentError, "You need to supply at least one attribute" if attributes.empty?
        
        normalizers = []
        normalizers << Normalizer.new unless normalizations.delete(:default) === false
        
        normalizations.each do |key, options|
          begin
            #klass = "#{Inflector.camelize(key)}Normalizer"
            #klass = const_defined?(klass) ? const_get(klass) : (Object.const_defined?(klass) ? Object.const_get(klass) : eval("VacuumCleaner::Normalizations::#{klass}"))
            normalizers << const_get("#{Inflector.camelize(key)}Normalizer").new(options === true ? {} : options)
          rescue NameError
            raise ArgumentError, "Unknown normalizer: '#{key}'"
          end
        end
        
        attributes.each do |attribute|
          rb_src = unless instance_methods.include?("#{attribute}=")
            "@#{attribute} = value"
          else
            send(:alias_method, "#{attribute}#{VacuumCleaner::Normalizations::WITHOUT_NORMALIZATION_SUFFIX}=", "#{attribute}=")
            "send('#{attribute}#{VacuumCleaner::Normalizations::WITHOUT_NORMALIZATION_SUFFIX}=', value)"
          end

          metaklass.send(:define_method, :"normalize_#{attribute}") do |value|
            value = normalizers.inject(value) { |v,n| n.normalize(self, attribute.to_sym, v) }
            block_given? ? (block.arity == 1 ? yield(value) : yield(self, attribute.to_sym, value)) : value
          end
          
          module_eval "def #{attribute}=(value); value = self.class.send(:'normalize_#{attribute}', value); #{rb_src} end", __FILE__, __LINE__
        end
      end      
    end
    
    module Inflector
      # Call either <tt>value.to_s.camelize</tt> if it responds to <tt>:camelize</tt>, else
      # simple implementation taken directly from http://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L25
      # of a default camelize behaviour.
      def self.camelize(value)
        value = value.to_s
        value.respond_to?(:camelize) ? value.camelize : value.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      end
    end
  end
end

# load standard normalizations
Dir[File.dirname(__FILE__) + "/normalizations/*.rb"].sort.each do |path|
  require "vacuum_cleaner/normalizations/#{File.basename(path)}"
end