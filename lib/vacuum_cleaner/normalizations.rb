module VacuumCleaner
  # Suffix added to existing setter methods
  WITHOUT_NORMALIZATION_SUFFIX = "_without_normalization"
  
  module Normalizations
    
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
            normalizers << const_get("#{VacuumCleaner.camelize_value(key)}Normalizer").new(options === true ? {} : options)
          rescue NameError
            raise ArgumentError, "Unknown normalizer: '#{key}'"
          end
        end
        
        attributes.each do |attribute|
          attribute = attribute.to_sym
          send(:define_method, :"normalize_#{attribute}") do |value|
            value = normalizers.inject(value) { |v,n| n.normalize(self, attribute, v) }
            block_given? ? (block.arity == 1 ? yield(value) : yield(self, attribute, value)) : value
          end
          original_setter = "#{attribute}#{VacuumCleaner::WITHOUT_NORMALIZATION_SUFFIX}=".to_sym
          send(:alias_method, original_setter, "#{attribute}=") if instance_methods.include?(RUBY_VERSION =~ /^1.9/ ? :"#{attribute}=" : "#{attribute}=")
                    
          rb_src = <<-RUBY
            def #{attribute}=(value)                                                                          #  1.  def name=(value)
              value = send(:'normalize_#{attribute}', value)                                                  #  2.    value = send(:'normalize_name', value)
              return send(#{original_setter.inspect}, value) if respond_to?(#{original_setter.inspect})       #  3.    return send(:'name_wo...=', value) if respond_to?(:'name_wo...=')
              return send(:write_attribute, #{attribute.inspect}, value) if respond_to?(:write_attribute)     #  4.    return send(:write_attribute, :name, value) if respond_to?(:write_attribute)
              @#{attribute} = value                                                                           #  5.   @name = value
            end                                                                                               #  6.  end
          RUBY
          
          module_eval rb_src, __FILE__, __LINE__
        end
      end      
    end    
  end
  
  # Okay, because this library currently does not depend on
  # <tt>ActiveSupport</tt> or anything similar an "independent" camelizing process is
  # required.
  #
  # <b>How it works:</b> If <tt>value.to_s</tt> responds to <tt>:camelize</tt>, then call it else, use implementation
  # taken from http://github.com/rails/rails/blob/master/activesupport/lib/active_support/inflector/methods.rb#L25
  def camelize_value(value)
    value = value.to_s
    value.respond_to?(:camelize) ? value.camelize : value.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
  end
  module_function :camelize_value
end

# load standard normalizations
Dir[File.dirname(__FILE__) + "/normalizations/*.rb"].sort.each do |path|
  require "vacuum_cleaner/normalizations/#{File.basename(path)}"
end