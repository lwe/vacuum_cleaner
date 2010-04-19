require 'test_helper'
require 'vacuum_cleaner/normalizer'
require 'vacuum_cleaner/normalizations/url'

class VacuumCleaner::Normalizations::UrlTest < Test::Unit::TestCase
  include VacuumCleaner::Normalizations
  
  #
  #   normalizes :homepage, :url => true
  #   normalizes :ftp, :url => "ftp://"
  #   normalizes :uri, :url => { :scheme => "http://", :unless => %r{\A(https?://|ftp://|jabber:)} }
  #
  context "UrlNormalizer#normalize_value" do
    should "ignore <nil>" do
      assert_nil UrlNormalizer.new.normalize_value(nil)
    end
    
    should "prefix string with 'http://' if string does not begin with it" do
      assert_equal "http://google.com", UrlNormalizer.new.normalize_value("google.com")
    end
    
    should "not prefix string with 'http://' if string already begins with http or https" do
      assert_equal "http://google.com/", UrlNormalizer.new.normalize_value("http://google.com/")
      assert_equal "https://docs.google.com/", UrlNormalizer.new.normalize_value("https://docs.google.com/")
    end
    
    should "allow to specify custom scheme, like ftp://" do
      assert_equal "ftp://ftp.sacred-heart.com", UrlNormalizer.new("ftp://").normalize_value("ftp.sacred-heart.com")
      assert_equal "ftp://ftp.sacred-heart.com", UrlNormalizer.new("ftp://").normalize_value("ftp://ftp.sacred-heart.com")
    end
    
    should "allow to specify :scheme and custom regex to exclude/allow certain protocols" do
      n = UrlNormalizer.new(:scheme => "http://", :unless => %r{\A(https?://|ftp://|jabber:)})
      assert_equal "http://google.com", n.normalize_value("google.com")
      assert_equal "jabber:jd@sh.com", n.normalize_value("jabber:jd@sh.com")
      assert_equal "https://docs.google.com", n.normalize_value("https://docs.google.com")
    end
    
    should "normalize to <nil> if only scheme is given" do
      assert_nil UrlNormalizer.new.normalize_value("http://")
      assert_nil UrlNormalizer.new.normalize_value(" http://\n")
    end
    
    should "be stupid, so if some other scheme is used, just override it, haha" do
      assert_equal "xmpp:mailto:jd@sacred-heart.com", UrlNormalizer.new("xmpp:").normalize_value("mailto:jd@sacred-heart.com")
    end
  end
end
