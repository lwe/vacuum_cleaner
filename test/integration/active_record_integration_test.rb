require 'test_helper'

# load ActiveRecord
require 'active_record'
require 'vacuum_cleaner'

# open connection to in-memory db
ActiveRecord::Base.establish_connection({
  :adapter => RUBY_PLATFORM =~ /java/ ? 'jdbcsqlite3' : 'sqlite3',
  :database => ':memory:'})

puts "Running integration tests against: active_record-#{ActiveRecord::VERSION::STRING}"

class ActiveRecordIntegrationTest < ::Test::Unit::TestCase
  context "ActiveRecord::Base" do
    should "include VacuumCleaner::Normalizations" do
      assert ActiveRecord::Base.included_modules.include?(VacuumCleaner::Normalizations)
    end

    context "with a sqlite connection" do
      setup do
        # build db
        ActiveRecord::Base.connection.create_table :dummies, :force => true do |t|
          t.column :name, :string
        end
      end

      should "respond to normalize and normalize :name on set" do
        klass = Class.new(ActiveRecord::Base) do; self.table_name = 'dummies'; normalizes :name end

        object = klass.new({ :name => "Elliot Reid\n" })
        assert_equal "Elliot Reid", object.name
      end

      should "normalize on +object.name+ accessors as well" do
        klass = Class.new(ActiveRecord::Base) do; self.table_name = 'dummies'; normalizes :name end

        object = klass.new
        object.name = " Dorian\t\n"
        assert_equal "Dorian", object.name
      end

      should "not normalize when accessing directly using []/write_attribute" do
        klass = Class.new(ActiveRecord::Base) do; self.table_name = 'dummies'; normalizes :name end
        object = klass.new
        object[:name] = "Elliot Reid\n\t"
        assert_equal "Elliot Reid\n\t", object.name
      end

      should "not normalize when reading from database" do
        ActiveRecord::Base.connection.execute "INSERT INTO dummies VALUES(NULL,'Elliot Reid\n\t');"
        klass = Class.new(ActiveRecord::Base) do; self.table_name = 'dummies'; normalizes :name end
        assert_equal "Elliot Reid\n\t", klass.last.name
      end

      should "work with customized setter methods, masking AR-attributes" do
        klass = Class.new(ActiveRecord::Base) do; self.table_name = 'dummies'; def name=(n); self[:name] = n; end; normalizes :name end
        object = klass.new :name => " J.D.\n"
        assert_equal "J.D.", object.name
        object.name = "Dorian\n\r"
        assert_equal "Dorian", object.name
      end
    end
  end
end
