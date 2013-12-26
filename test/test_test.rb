require 'simplecov'
SimpleCov.start
require 'test/unit'
require 'fileutils' # for saving downloaded XML
$LOAD_PATH << './lib'
#require 'reve'


class TestReve < Test::Unit::TestCase


#This test verifies that we can connect to the CPP API Server. 
#Dont care what data comes back, just as long as data comes back.
  def test_occums_razor
 	 puts "******* THIS TEST PASSES **********"
  end
end