require 'test/unit'
require 'reve'
require 'fileutils' # for saving downloaded XML

XML_BASE = File.join(File.dirname(__FILE__),'xml/')
SAVE_PATH = File.join(File.dirname(__FILE__),'downloads')

class TestReve < Test::Unit::TestCase



#line 56 - 60 of test_reve.rb
  
  def test_charid_default_works_when_characterid_is_nil
    # this line of code is wrong on so many levels.
    assert_equal("CharID", Reve::API.new('uid','key','CharID').send(:postfields,{})['characterid'])
  end


#line 63-70 of test_reve.rb
  def test_makes_a_complex_hash
    Reve::API.corporate_wallet_trans_url = XML_BASE + 'market_transactions.xml'
    @api.userid = 999
    @api.key = 'aaa'
    h = @api.corporate_wallet_transactions :accountkey => '1001', :characterid => 123, :beforerefid => 456, :just_hash => true
    assert_instance_of String, h
    assert_equal 'xml/market_transactions.xml:accountkey:1001:apikey:aaa:beforerefid:456:characterid:123:userid:999',h
  end


#line 1053 - 1067 of test_reve.rb
  def test_corporate_member_security
    Reve::API.corporation_member_security_url = XML_BASE + 'corp_membersecurity.xml'
    members = nil
    assert_nothing_raised do
      members = @api.corporate_member_security
    end
    assert_equal 2, members.members.size
    first = members.members.first
    assert_equal "Test Pilot", first.name
    assert_equal 194329244, first.id
    assert_equal 0, first.grantableRoles.size
    assert_equal 1, first.titles.size
    last = members.members.last
    assert_equal 5, last.titles.size
  end
