require 'test/unit'
require 'reve/extensions'

class CattrReaderTest;cattr_reader :test_reader;end
class CattrWriterTest;cattr_writer :test_writer;end
class CattrReadWriterTest;cattr_accessor :test_both;end

class TestExtensions < Test::Unit::TestCase

  def test_nil_to_date
    assert_nil nil.to_date
  end
  def test_nil_to_time
    assert_nil nil.to_time
  end
  
  
  def test_stringify_keys
    h = { :key => 'value', :tone => 'bar' }
    m = h.stringify_keys
    assert_not_nil m['key']
    assert_not_nil m['tone']
    assert_nil m[:key]
    assert_nil m[:tone]
  end
  
  def test_stringify_keys!
    h = { :key => 'value', :tone => 'bar' }
    h.stringify_keys!
    assert_not_nil h['key']
    assert_not_nil h['tone']
    assert_nil h[:key]
    assert_nil h[:tone]
  end
  
  
  def test_cattr_reader
    assert CattrReaderTest.public_instance_methods.include?('test_reader')
  end
  def test_cattr_writer
    assert CattrWriterTest.public_instance_methods.include?('test_writer=')
  end
  def test_cattr_accessor
    assert CattrReadWriterTest.public_instance_methods.include?('test_both')
    assert CattrReadWriterTest.public_instance_methods.include?('test_both=')
  end
  
  def test_string_to_time_clean
    t = Time.at(1201994389) # Sat Feb 02 23:19:49 UTC 2008
    str = "Sat Feb 02 23:19:49 UTC 2008"
    assert_equal t,str.to_time
  end
  def test_string_to_time_unclean
    assert_equal "abcd123", "abcd123".to_time
  end
  def test_string_to_i_clean
    assert_equal 42,"42".to_i
  end
  def test_string_to_i_unclean
    assert "abcd123","abcd123".to_i
  end
  
end