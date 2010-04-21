Vacuum Cleaner
==============

A Ruby (and Rails) attribute normalization gem, which is supposedly [semver](http://semver.org/)-compliant.

Known to work with Ruby-1.9, JRuby and both Rails 2.3.x and 3. If there are any issues, please file a
[bug report](http://github.com/lwe/vacuum_cleaner/issues), or fix it and send me a pull request.

Installation
------------

1. Install as gem from [rubygems](http://rubygems.org/gems/vacuum_cleaner): `sudo gem install vacuum_cleaner`.
   Then load it in your app: `require 'rubygems'; require 'vacuum_cleaner'`      
2. Install as gem using [bundler](http://github.com/carlhuda/bundler), add `gem "vacuum_cleaner"` to your
   `Gemfile` and run `bundle install`
3. Or as a Rails plugin, for Rails 2.x run `./script/plugin install git://github.com/lwe/vacuum_cleaner.git`, when using Rails 3.x
   goodeness run `rails plugin install git://github.com/lwe/vacuum_cleaner.git`

Usage
-----

It creates a new setter method for an attribute and thus allows the gem to reprozess the input value.

    class Doctor
      include VacuumCleaner::Normalizations  # enables #normalizes, NOTE: not required for ActiveRecord models
      attr_accessor :name                    # create some reader/writter
      
      normalizes :name                       # enables strip/clean-up magic on attribute :name
    end
    
Using `normalizes` just adds a default normalization implemenation, which removes leading/trailing
whitespace and converts spaces only to `nil`. Everything happens upon "set".

    @doc = Doctor.new
    @doc.name = "  Elliot Reid\n\t"
    @doc.name   # => "Elliot Reid" => trailing space was stripped
    
    @doc.name = "\t\n"
    @doc.name   # => nil => converted to nil

Okay, this is how it basically works, the `normalizes` call just generates a new setter method,
which `normalizes` the input value and then calls the original setter method.

What else can be done then?

    # can be used with multiple attributes (if they all share the same normalizer)
    normalizes :name, :company
    
    # provides a fancy :downcase and :upcase normalizer (guess what they do)
    normalizes :email, :downcase => true
    # "JD@EXAMPLE.COM \n" => "jd@example.com"
    
    # provides a :method normalizer which takes a string/symbol as argument which is
    # then called upon the resulting value (if it respond_to)
    normalizes :name, :method => :titleize
    # "carla ESPINOSA" => "Carla Espinosa" PS: only works if ActiveSupport is available :)
    
    # or a simple URL normalizer, which prefixes http:// if not starting with
    # http or https
    normalizes :homepage, :url => true
    # "google.com" => "http://google.com"
    # "http://example.com" => "http://example.com" PS: left as is

Take a look at `VacuumCleaner::Normalizer`, about how the process works and how custom
reusable normalizers can be written. For the-quick-fix-that-shouldnt-have-been-used-but-was
case or if there's no reuse, `normalizes` takes a block as argument which is called
after any other normalizer in the chain. Note that normalizers are not halted, nor stopped
if they return `nil` or `false` or something similar, so ensure that case is handled properly.

    # strips all whitespace within a string
    normalizes(:phone) { |value| value.to_s.gsub(/\s+/, '') unless value.nil? }    
    # "\t+45 123 123  " => "+45123123" PS: yes, the standard strip etc. magic is still run
    
    # no need for the default normalizer and feeling really custom?
    normalizes(:phone, :default => false, :upcase => true) { |value| value.to_s.strip.gsub(/\s+/, '') }
    # "\t0800 sacred heart" => "0800SACREDHEART"
    # "\t\n" => ""
    # nil => ""
    
Need access to the full object within the block? As easy as:

    # naming J.D. after some girly girl?
    normalizes(:first_name) do |obj, attribute, value|
      obj.name == "Dorian" ? %w{Agnes Shirley Denise}[rand(3)] : value
    end

Background
----------

As mentoined earlier `normalizes` creates a new setter method, so let's shortly take a look
at how.

    normalizes(:name)
    
    # 1. creates a :normalize_name method, which contains the normalization chain, block etc.
    # 2. if :name= exists, it's aliased to :name_without_normalization=
    # 3. creates a new :name= method, which calls :normalize_name, then tries to
    #    set the normalized value by one of:
    #    a) calling :name_without_normalization=, if defined
    #    b) self[:name] = v, if it responds to :[]= (for ActiveRecord support)
    #    c) or, as a fallback, sets @name to the result of :normalize_name

Lessons learned, when the need arises to set the value without any normalization and there's
a setter just use `@object.name_without_normalization = "har har har\n\t"`. Feel free to
completly override `normalize_<attribute>`, but a much smarter way to add very custom normalizers
is by a) providing a block to `normalizes` or b) create a custom `VacuumCleaner::Normalizer`
implementation.

Some info about the different files, might be a good place to look at when trying to figure
out how to write custom `VacuumCleaner::Normalizer` implemenations, or for a look at how
it works.

    lib/vacuum_cleaner/normalizer.rb        # Base Normalizer implementation
    lib/vacuum_cleaner/normalizations/*.rb  # Some default Normalizer implementations, like url, downcase etc.
    lib/vacuum_cleaner/normalizations.rb    # Provides the `normalizes` method and all the logic etc.
    