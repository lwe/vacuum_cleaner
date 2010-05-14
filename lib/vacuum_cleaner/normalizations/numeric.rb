module VacuumCleaner
  module Normalizations
    
    # The numeric normalizer tries to normalize a numeric string input
    # like <tt>CHF 12'000.--</tt> into a string parseable by {{Kernel.Float}}
    # or similar (result would be <tt>12000.</tt>).
    #
    # It basically strips any non valid character for a number from the
    # input string (scientific notation is currently not support), so all
    # whitespace, currency symbols and units are stripped. Furthermore also
    # the decimal points are normalized, because in Germany numbers can look
    # like: <tt>EUR 12.000,50</tt> and in Switzerland they can look like
    # <tt>1,5 Mio.</tt>. So the normalizer tries to ensure that both are
    # numbers parseable by {{Kernel.Float}}, by intelligently trying to
    # figure out the seperator used and converting it to <tt>.</tt>.
    #
    # All values which do not respond to <tt>to_str</tt> are left as is.
    #
    # Note: no conversion or anything similar is done! The value wont be
    # converted to a +Fixnum+ or whatever and will be left as string.
    # When used with Rails validations, this might also certainly render
    # the validations to check if it's a valid number obsolete, yet all
    # the stuff about min/max, fixed only etc. work of course like a charm.
    #
    class NumericNormalizer < Normalizer
      def normalize_value(value)
        if value.respond_to?(:to_str)
          num = value.to_str.gsub(/\s*/, '') # I. remove all spaces
          num.gsub!(/([^\d\-])\./, '\1')     # II. remove misleading points in units like "Mio." or "SFr."
          num.gsub!(/[^\d,\.\-]/i, '')       # III. remove all chars we are not interested in, like anything not related to numeric :)
          num.gsub!("--", '')                # IV. remove double dashes, like often used in CH
          num = num.gsub(",", '.').gsub(".") { $'.include?(".") ? "" : "." }.gsub(/\.\z/, '')  # V. intelligently convert comma to points...
        else
          value
        end
      end      
    end
  end
end