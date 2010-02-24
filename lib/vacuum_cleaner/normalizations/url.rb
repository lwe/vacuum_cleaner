module VacuumCleaner
  module Normalizations
    class UrlNormalizer < Normalizer
      def initialize(options = {})
        options = { :scheme => "http://", :unless => %r{\Ahttps?://}i } if options.nil? || options.empty?
        options = { :scheme => options, :unless => %r{\A#{options}}i } unless options.is_a?(Hash)
        super(options)
      end
      
      def normalize_value(value)
        value =~ options[:unless] ? value : "#{options[:scheme]}#{value}" unless value.nil?
      end
    end
  end
end