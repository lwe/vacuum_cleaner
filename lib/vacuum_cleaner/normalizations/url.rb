module VacuumCleaner
  module Normalizations
    
    # Normalizer which is used to prefix strings with a scheme, if missing.
    # This is useful to ensure, that an input field always has e.g. the
    # "http://" scheme added. Please note, that this normalizer does not
    # validate a URL in any way.
    #
    #   normalizes :homepage, :url => true
    #
    # Accepts a string as input, so to normalize for instance FTP URLs.
    #
    #   normalizes :download_url, :url => "ftp://"
    #
    # To make further customizations, the constructor accepts a hash.
    #
    #   normalizes, :contact_url, :url => { :scheme => "http://",
    #                                       :unless => %r{\A(https?://|xmpp:|gtalk:|mailto:)} }
    #
    # The key <tt>:scheme</tt> is always used as the prefix, when the input
    # does not a match the regex in <tt>:unless</tt>.
    class UrlNormalizer < Normalizer
      
      # Accepts either a hash or a string.
      def initialize(options = {})
        options = { :scheme => "http://", :unless => %r{\Ahttps?://}i } if options.nil? || options.empty?
        options = { :scheme => options, :unless => %r{\A#{options}}i } unless options.is_a?(Hash)
        super(options)
      end
      
      # Prefixes input with <tt>options[:scheme]</tt> if it doesn't matches
      # <tt>options[:unless]</tt>.
      def normalize_value(value)
        value = super # just ensure that default stripping/cleaning is done already
        return nil if value == options[:scheme]
        value =~ options[:unless] ? value : "#{options[:scheme]}#{value}" unless value.nil?
      end
    end
  end
end