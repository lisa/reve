# -*- coding: utf-8 -*-
# Tests designed to run with autotest.
require 'test/unit'
require 'reve'
require 'fileutils' # for saving downloaded XML


class TestReve < Test::Unit::TestCase


#This test verifies that we can connect to the CPP API Server. 
#Dont care what data comes back, just as long as data comes back.
  def test_End_to_End_Connectivity_Test
    api = Reve::API.new
    errors = api.errors 
    assert_not_nil(errors.inspect)
  end
end