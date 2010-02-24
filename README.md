Vacuum Cleaner
==============

A Ruby (and Rails) attribute normalization gem, which is supposedly [semver](http://semver.org/)-compliant.

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
    
    @doc = Doctor.new
    
    # set name with leading/trailing spaces
    @doc.name = "  Elliot Reid\n\t"
    @doc.name   # => "Elliot Reid"
    
    # empty strings => nil
    @doc.name = "\t\n"
    @doc.name   # => nil

Okay, this is it. Now, let the fun part begin...

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
    
Assuming this already allows to fix 99.9% of all attribute normalization cases, if there's
that special need, then `normalizes` accepts a block:

    # strips all whitespace within a string
    normalizes(:phone) { |value| value.to_s.gsub(/\s+/, '') unless value.nil? }    
    # "\t+45 123 123  " => "+45123123" PS: yes, the standard strip etc. magic is still run
    
    # no need for the default normalizer and feeling really custom?
    normalizes(:phone, :default => false, :upcase => true) { |value| value.to_s.strip.gsub(/\s+/, '') }
    # "\t0800 sacred heart" => "0800SACREDHEART"
    # "\t\n" => ""
    # nil => ""
    
Need access to the object within the block? As easy as:

    # naming J.D. after some girly girl?
    normalizes(:first_name) do |obj, attribute, value|
      obj.name == "Dorian" ? %w{Agnes Shirley Denise}[rand(3)] : value
    end
