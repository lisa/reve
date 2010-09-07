# Tests designed to run with autotest.
require 'test/unit'
require 'reve'
require 'fileutils' # for saving downloaded XML

XML_BASE = File.join(File.dirname(__FILE__),'xml/')
SAVE_PATH = File.join(File.dirname(__FILE__),'downloads')

class TestReve < Test::Unit::TestCase

  def setup
    @api = get_api
    assert_nil @api.last_hash
    FileUtils.mkdir(SAVE_PATH) rescue nil
  end
  def teardown
    FileUtils.rm_rf(SAVE_PATH)
  end

  def test_makes_right_api_empty
    api = get_api
    assert_instance_of Reve::API, api
    assert_equal "", api.userid
    assert_equal "", api.key
    assert_equal "", api.charid
  end
  def test_makes_right_api_1_param
    api = get_api(12345)
    assert_instance_of Reve::API, api
    assert_equal "12345", api.userid
    assert_equal "", api.key
    assert_equal "", api.charid   
  end
  def test_makes_right_api_2_param
    api = get_api(12345,54321)
    assert_instance_of Reve::API, api
    assert_equal "12345", api.userid
    assert_equal "54321", api.key
    assert_equal "", api.charid   
  end  
  def test_makes_right_api_3_param
    api = get_api(12345,54321,'abcde')
    assert_instance_of Reve::API, api
    assert_equal "12345", api.userid
    assert_equal "54321", api.key
    assert_equal "abcde", api.charid   
  end
  
  def test_makes_a_simple_hash
    Reve::API.alliances_url = XML_BASE + 'alliances.xml'
    h = @api.alliances :just_hash => true
    assert_instance_of String, h
    assert_equal "xml/alliances.xml", h    
  end
  
  def test_charid_default_works_when_characterid_is_nil
    # this line of code is wrong on so many levels.
    assert_equal("CharID", Reve::API.new('uid','key','CharID').send(:postfields,{})['characterid'])
  end

  def test_makes_a_complex_hash
    Reve::API.corporate_wallet_trans_url = XML_BASE + 'market_transactions.xml'
    @api.userid = 999
    @api.key = 'aaa'
    h = @api.corporate_wallet_transactions :accountkey => '1001', :characterid => 123, :beforerefid => 456, :just_hash => true
    assert_instance_of String, h
    assert_equal 'xml/market_transactions.xml:accountkey:1001:apikey:aaa:beforerefid:456:characterid:123:userid:999',h
  end

  def test_bad_xml
    Reve::API.training_skill_url = XML_BASE + 'badxml.xml'
    skill = @api.skill_in_training
    assert_not_nil @api.last_hash
  end
  
  def test_saving_xml_works
    @api.save_path = SAVE_PATH
    alliances = @api.alliances :url => File.join(XML_BASE,'alliances.xml')
    assert File.exists?(File.join(SAVE_PATH,'alliances',@api.cached_until.to_i.to_s + '.xml'))
    assert_equal(
      File.open(File.join(XML_BASE,'alliances.xml')).read,
      File.open(File.join(SAVE_PATH,'alliances',@api.cached_until.to_i.to_s + '.xml')).read)
  end
  

  def test_saving_xml_when_save_path_is_nil
    assert_nil @api.save_path
    alliances = @api.alliances :url => File.join(XML_BASE,'alliances.xml')
    assert ! File.exists?(File.join(SAVE_PATH,'alliances',@api.cached_until.to_i.to_s + '.xml'))
  end
  
  # We want to see <url /> in the saved XML because that's what came from the source
  def test_saving_xml_with_bad_short_tag
    @api.save_path = SAVE_PATH
    @corpsheet = @api.corporation_sheet :url => File.join(XML_BASE,'corporation_sheet.xml')
    assert_equal "", @corpsheet.url
    assert File.open(File.join(SAVE_PATH,'corporation_sheet',@api.cached_until.to_i.to_s + '.xml')).read.include?("<url />")  
  end
  
  def test_saving_xml_when_404
    @api.save_path = SAVE_PATH
    alliances = nil
    assert_raise Errno::ENOENT do
      alliances = @api.alliances :url => File.join(XML_BASE,rand.to_s)      
    end
    assert_nil @api.cached_until
    assert_equal 0, Dir.glob(File.join(SAVE_PATH,'alliances','*.xml')).size # no XML saved
  end
  
  # File.split exists and File is not a String or URI class as permitted in Reve::API#get_xml.
  # This means as a parameter it will pass through Reve::API#compute_hash method and
  # get to Reve::API#get_xml
  def test_for_bad_uri_passed_to_method
    assert_raise Reve::Exceptions::ReveNetworkStatusException do
      @api.character_sheet :url => File
    end
  end
  
  def test_check_exception_with_bad_xml_document
    assert_raise ArgumentError do
      @api.send(:check_exception,nil)
    end
  end
  
  def test_errors_api_call
    errors = nil
    assert_nothing_raised do
      errors = @api.errors :url => File.join(XML_BASE,'errors.xml')
    end
    assert errors.all? { |e| e.kind_of?(Reve::Classes::APIError) }
    assert_equal 61, errors.size # 61 errors in total
    errors.each do |error|
      assert_not_nil(error.code)
      assert_not_nil(error.text)
    end
  end
  
  def test_research_api_call
    Reve::API.research_url = XML_BASE + 'research.xml'
    research = nil
    assert_nothing_raised do
      research = @api.research :characterid => 123
    end
    assert_not_nil(research)
    assert_not_nil(@api.last_hash)
    assert_equal(4, research.size)
    research.each do |ri|
      assert_kind_of(Fixnum, ri.agent_id)
      assert_kind_of(Fixnum, ri.skill_type_id)
      assert_kind_of(Time, ri.research_started_at)
      assert_kind_of(Float, ri.points_per_day)
      assert_kind_of(Float, ri.remainder_points)
    end
  end
  
  
  def test_corporation_sheet_clean
    Reve::API.corporation_sheet_url = XML_BASE + 'corporation_sheet.xml'
    corporation = nil
    assert_nothing_raised do
      corporation = @api.corporation_sheet :characterid => 123
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 150212025, corporation.id
    assert_equal "Banana Republic", corporation.name
    assert_equal "BR", corporation.ticker
    assert_equal(150208955, corporation.ceo_id)
    assert_equal("Mark Roled", corporation.ceo_name)
    assert_equal(60003469, corporation.station_id)
    assert_equal("Jita IV - Caldari Business Tribunal Information Center", corporation.station_name)
    assert_equal "Garth's testing corp of awesome sauce, win sauce as it were. In this corp...<br><br>IT HAPPENS ALL OVER", corporation.description
    assert_equal("", corporation.url)
    assert_equal(150430947, corporation.alliance_id)
    assert_equal("The Dead Rabbits", corporation.alliance_name)
    assert_equal 93.7, corporation.tax_rate
    assert_equal(3, corporation.member_count)
    assert_equal(6300, corporation.member_limit)
    assert_equal(1, corporation.shares)
    assert_equal "DIVISION", corporation.divisions.select { |d| d.key == 1003 }.first.description
    corporation.divisions.each do |d|
      assert_not_nil(d.key)
      assert_not_nil(d.description)
    end    
    assert_equal "Master Wallet", corporation.wallet_divisions.select { |d| d.key == 1000 }.first.description
    corporation.wallet_divisions.each do |wd|
      assert_not_nil(wd.key)
      assert_not_nil(wd.description)
    end         
    assert_equal 0, corporation.logo.graphic_id
    assert_equal 681, corporation.logo.color_1
    assert_equal 676, corporation.logo.color_2
    assert_equal 448, corporation.logo.shape_1
    assert_equal 418, corporation.logo.shape_3
    assert_equal 0, corporation.logo.color_3
    assert_equal 0, corporation.logo.shape_2
  end
  
  def test_conqurable_stations_clean
    Reve::API.conqurable_outposts_url = XML_BASE + 'conqurable_stations.xml'
    stations = nil
    assert_nothing_raised do
      stations = @api.conqurable_stations
    end
  
    assert_equal 3, stations.size
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    
    stations.each do |station|
      assert_not_nil station.id
      assert_not_nil station.name
      assert_not_nil station.type_id
      assert_not_nil station.system_id
      assert_not_nil station.corporation_id
      assert_not_nil station.corporation_name
      assert_not_nil station.system_id
    end
  end
  
  def test_convert_characterids_to_names
    ids = [ 797400947,892008733 ] # CCP Garthagk, Raquel Smith
    names = []
    assert_nothing_raised do
      names = @api.character_name :url => XML_BASE + 'charactername.xml', :ids => ids
    end
    assert_equal 2, names.size
    names.each do |name|
      assert_not_nil(name.name)
      assert_not_nil(name.id)
    end
    actual_names = names.collect { |n| n.name }
    assert actual_names.include?('CCP Garthagk')
    assert actual_names.include?('Raquel Smith')
  end
  
  def test_convert_characternames_to_ids
    names = [ 'CCP Garthagk', 'Raquel Smith' ] # 797400947,892008733
    ids = []
    assert_nothing_raised do
      ids = @api.names_to_ids :url => XML_BASE + 'characterid.xml', :names => names
    end
    assert_equal 2, ids.size
    ids.each do |id|
      assert_not_nil(id.id)
      assert_not_nil(id.name)
    end
    actual_ids = ids.collect { |n| n.id }
    assert actual_ids.include?(797400947)
    assert actual_ids.include?(892008733)
  end

  def test_personal_industry_jobs_clean
    Reve::API.personal_industry_jobs_url = XML_BASE + 'industryjobs.xml'
    jobs = nil
    assert_nothing_raised do
      jobs = @api.personal_industry_jobs
    end
    assert_equal 2, jobs.size
    # All things got assigned something.
    jobs.each do |job|
      [ :id, :assembly_line_id, :container_id, :installed_item_id, :installed_item_location_id,
        :installed_item_quantity, :installed_item_productivity_level, :installed_item_material_level,
        :installed_item_licensed_production_runs_remaining, :output_location_id, :installer_id, :runs,
        :licensed_production_runs, :installed_system_id, :container_location_id, :material_multiplier,
        :char_material_multiplier, :time_multiplier, :char_time_multiplier, :installed_item_type_id,
        :output_type_id, :container_type_id, :installed_item_copy, :completed, :completed_successfully, 
        :installed_item_flag, :output_flag, :activity_id, :completed_status, :installed_at, 
        :begin_production_at, :end_production_at, :pause_production_time ].each do |att|
          assert_not_nil job.send(att)
      end
    end
	assert jobs.last.installed_system_id != 0
  end
  
  def test_corporate_industry_jobs_clean
    Reve::API.corporate_industry_jobs_url = XML_BASE + 'industryjobs.xml'
    jobs = nil
    assert_nothing_raised do
      jobs = @api.corporate_industry_jobs
    end
    assert_equal 2, jobs.size
    # All things got assigned something.
    jobs.each do |job|
      [ :id, :assembly_line_id, :container_id, :installed_item_id, :installed_item_location_id,
        :installed_item_quantity, :installed_item_productivity_level, :installed_item_material_level,
        :installed_item_licensed_production_runs_remaining, :output_location_id, :installer_id, :runs,
        :licensed_production_runs, :installed_system_id, :container_location_id, :material_multiplier,
        :char_material_multiplier, :time_multiplier, :char_time_multiplier, :installed_item_type_id,
        :output_type_id, :container_type_id, :installed_item_copy, :completed, :completed_successfully, 
        :installed_item_flag, :output_flag, :activity_id, :completed_status, :installed_at, 
        :begin_production_at, :end_production_at, :pause_production_time ].each do |att|
          assert_not_nil job.send(att)
      end
    end
  end
  
  def test_faction_war_system_stats_clean(skip_preamble = false,stats = nil)
    Reve::API.faction_war_occupancy_url = XML_BASE + 'map_facwarsystems.xml'
    unless skip_preamble # not best practice but will get the job done!
      stats = nil
      assert_nothing_raised do
        stats = @api.faction_war_system_stats
      end
    end
    assert stats.all? { |s| s.kind_of?(Reve::Classes::FactionWarSystemStatus) }
    assert_equal(4, stats.size)
    stats.each do |sys|
      # can't assert_not_nil faction_id or faction_name since they may be nil
      assert_not_nil(sys.system_id)
      assert_not_nil(sys.system_name)
      assert_not_nil(sys.contested)
    end
    assert_equal(1, stats.select { |s| s.faction_id == 500001 }.size)
    assert_equal(1, stats.select { |s| s.faction_id == 500002 }.size)
    assert_equal(1, stats.select { |s| ! s.contested }.size)
    assert_equal(2, stats.select { |s| s.faction_id.nil? }.size)
    assert_equal(3, stats.select { |s| s.contested }.size)
  end
  
  def test_faction_war_system_stats_alias_clean
    Reve::API.faction_war_occupancy_url = XML_BASE + 'map_facwarsystems.xml'
    stats = nil
    assert_nothing_raised do
      stats = @api.faction_war_occupancy
    end
    test_faction_war_system_stats_clean(true,stats)
  end

  def test_faction_war_stats_clean
    Reve::API.general_faction_war_stats_url = XML_BASE + 'eve_facwarstats.xml'
    stats = nil
    assert_nothing_raised do
      stats = @api.faction_war_stats
    end
    assert_instance_of(Reve::Classes::EveFactionWarStat, stats)
    assert_equal(1707, stats.kills_yesterday)
    assert_equal(9737, stats.kills_last_week)
    assert_equal(27866, stats.kills_total)
    assert_equal(215674, stats.victory_points_yesterday)
    assert_equal(1738351, stats.victory_points_last_week)
    assert_equal(5613787, stats.victory_points_total)
    
    assert stats.faction_wars.all? { |w| w.kind_of?(Reve::Classes::FactionWar) }
    assert stats.faction_participants.all? { |w| w.kind_of?(Reve::Classes::FactionwideFactionWarParticpant) }
    assert_equal(8, stats.faction_wars.size)
    assert_equal(4, stats.faction_participants.size)
    stats.faction_wars.each do |war|
      assert_not_nil(war.faction_id)
      assert_not_nil(war.faction_name)
      assert_not_nil(war.against_id)
      assert_not_nil(war.against_name)
    end
    stats.faction_participants.each do |participant|
      assert_not_nil(participant.faction_id)
      assert_not_nil(participant.faction_name)
      assert_not_nil(participant.systems_controlled)
      assert_not_nil(participant.kills_yesterday)
      assert_not_nil(participant.kills_last_week)
      assert_not_nil(participant.kills_total)
      assert_not_nil(participant.victory_points_yesterday)
      assert_not_nil(participant.victory_points_last_week)
      assert_not_nil(participant.victory_points_total)
    end
    assert_not_nil(@api.cached_until)
  end
  def test_personal_factional_war_stats_clean
    Reve::API.personal_faction_war_stats_url = XML_BASE + 'char_facwarstats.xml'
    stats = nil
    assert_nothing_raised do
      stats = @api.personal_faction_war_stats
    end
    assert_instance_of Reve::Classes::PersonalFactionWarParticpant, stats
    assert_equal(500001, stats.faction_id)  
    assert_equal("Caldari State", stats.faction_name)
    assert_equal("2008-06-13 20:38:00".to_time, stats.enlisted_at)
    assert_equal(1, stats.current_rank)
    assert_equal(2, stats.highest_rank)
    assert_equal(3, stats.kills_yesterday)
    assert_equal(4, stats.kills_last_week)
    assert_equal(5, stats.kills_total)
    assert_equal(124, stats.victory_points_yesterday)
    assert_equal(124, stats.victory_points_last_week)
    assert_equal(506, stats.victory_points_total)
  end
  
  def test_corporate_factional_war_stats_clean
    Reve::API.corporate_faction_war_stats_url = XML_BASE + 'corp_facwarstats.xml'
    stats = nil
    assert_nothing_raised do
      stats = @api.corporate_faction_war_stats
    end
    assert_instance_of Reve::Classes::CorporateFactionWarParticpant, stats
    assert_equal(500001, stats.faction_id)  
    assert_equal("Caldari State", stats.faction_name)
    assert_equal("2008-06-10 22:10:00".to_time, stats.enlisted_at)
    assert_equal(4, stats.pilots)
    assert_equal(3, stats.kills_yesterday)
    assert_equal(4, stats.kills_last_week)
    assert_equal(5, stats.kills_total)
    assert_equal(124, stats.victory_points_yesterday)
    assert_equal(906, stats.victory_points_last_week)
    assert_equal(2690, stats.victory_points_total)
  end
  
  def test_faction_war_top_stats_clean
    Reve::API.top_faction_war_stats_url = XML_BASE + 'eve_facwartopstats.xml'
    stats = nil
    assert_nothing_raised do
      stats = @api.faction_war_top_stats
    end
    assert_kind_of(Reve::Classes::FactionWarTopStats, stats)
    [ :characters, :corporations, :factions ].each do |kind|
      [ :yesterday_kills, :last_week_kills, :total_kills ].each do |attr|
        assert_kind_of(Hash, stats.send(kind))
        assert_kind_of(Array, stats.send(kind)[attr])
        assert ! stats.send(kind)[attr].empty?
        [ :name, :id, :kills ].each do |c_attr|
          assert stats.send(kind)[attr].all? { |e| ! e.nil? }
        end
      end
      [ :last_week_victory_points, :yesterday_victory_points, :total_victory_points ].each do |attr|
        assert_kind_of(Hash, stats.send(kind))
        assert_kind_of(Array, stats.send(kind)[attr])
        assert ! stats.send(kind)[attr].empty?
        [ :name, :id, :victory_points ].each do |c_attr|
          assert stats.send(kind)[attr].all? { |e| ! e.nil? }
        end
      end
    end
    assert_equal(5, stats.characters[:yesterday_kills].size)
    assert_equal(6, stats.characters[:last_week_kills].size)
    assert_equal(7, stats.characters[:total_kills].size)
    [ :yesterday_kills, :yesterday_victory_points, :last_week_kills,
      :last_week_victory_points, :total_kills, :total_victory_points ].each do |attr|
        assert_equal(10,stats.corporations[attr].size)
    end
    [ :yesterday_kills, :yesterday_victory_points, :last_week_kills,
      :last_week_victory_points, :total_kills, :total_victory_points ].each do |attr|
        assert_equal(4,stats.factions[attr].size)
    end
  end

  def test_assets_clean
    Reve::API.personal_assets_url = XML_BASE + 'assets.xml'
    assets = nil
    assert_nothing_raised do
      assets = @api.personal_assets_list
    end
    assert_equal 18, assets.size # 18 single and 1 container
    contained_assets = assets.inject([]) { |ass,container| ass << container.assets }.flatten
    assert_equal(1, contained_assets.size) # We have a container it happens to have 1 asset in it
    contained_assets.each do |asset|
      assert_instance_of(Reve::Classes::Asset, asset)
      assert_not_nil(asset.item_id)
      assert_not_nil(asset.type_id)
      assert_not_nil(asset.quantity)
      assert_not_nil(asset.flag)
      assert_not_nil(asset.singleton)
    end
    assets.each do |asset|
      assert_instance_of(Reve::Classes::AssetContainer, asset)
      assert_not_nil(asset.item_id)
      assert_not_nil(asset.location_id)
      assert_not_nil(asset.type_id)
      assert_not_nil(asset.quantity)
      assert_not_nil(asset.flag)
      assert_not_nil(asset.singleton)
    end
  end

  # no need to test corporate cos they're the same.
  # TODO: Test with nested losses
  def test_kills_clean
    kills_cleanly(:personal_kills,File.join(XML_BASE,'kills.xml'))
  end
  
  def test_corporate_kills_clean
    kills_cleanly(:corporate_kills,File.join(XML_BASE,'kills.xml'))
  end

  def test_characters_clean
    Reve::API.characters_url = XML_BASE + 'characters.xml'
    chars = nil
    assert_nothing_raised do
      chars = @api.characters
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 1, chars.size
    chars.each do |char|
      assert_not_nil(char.name)
      assert_not_nil(char.id)
      assert_not_nil(char.corporation_name)
      assert_not_nil(char.corporation_id)
      assert_instance_of Reve::Classes::Character, char
    end
  end
  
  def test_starbases_clean
    Reve::API.starbases_url = XML_BASE + 'starbases.xml'
    bases = nil
    assert_nothing_raised do
      bases = @api.starbases(:characterid => 1)
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 4, bases.size
    bases.each do |starbase|
      assert_instance_of Reve::Classes::Starbase, starbase
      assert_not_nil starbase.type_id
      assert_not_nil starbase.id
      assert_not_nil starbase.system_id
      assert_not_nil starbase.moon_id
      assert_not_nil starbase.state
      assert_not_nil starbase.state_timestamp
      assert_not_nil starbase.online_timestamp
    end
  end
  
  def test_starbase_details_clean
    Reve::API.starbasedetail_url = XML_BASE + 'starbase_fuel.xml'
    detail = nil
    assert_nothing_raised do
      detail = @api.starbase_details(:starbaseid => 1,:characterid => 2)
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    
    assert_not_nil detail.state
    assert_kind_of Time, detail.state_timestamp
    assert_kind_of Time, detail.online_timestamp
    assert_instance_of Reve::Classes::StarbaseGeneralSettings, detail.general_settings
    assert_instance_of Reve::Classes::StarbaseCombatSettings, detail.combat_settings
    assert_equal 9, detail.fuel.size
    
    assert_not_nil detail.general_settings.usage_flags
    assert [TrueClass, FalseClass].include?(detail.general_settings.allow_corporation_members.class)
    assert [TrueClass, FalseClass].include?(detail.general_settings.allow_alliance_members.class)
    assert [TrueClass, FalseClass].include?(detail.general_settings.claim_sovereignty.class)
    
    assert_not_nil detail.combat_settings.on_standings_drop
    assert_not_nil detail.combat_settings.on_status_drop
    assert_not_nil detail.combat_settings.on_aggression
    assert_not_nil detail.combat_settings.on_corporation_war
    
    detail.fuel.each do |fuel|
      assert_not_nil fuel.type_id
      assert_not_nil fuel.quantity
    end
  end

  def test_alliances_clean
    Reve::API.alliances_url = XML_BASE + 'alliances.xml'
    alliances = nil
    assert_nothing_raised do
      alliances = @api.alliances
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 3, alliances.size
    corpsize = 0
    alliances.each do |alliance|
      assert_instance_of Reve::Classes::Alliance, alliance
      assert_not_equal 0, alliance.member_corporations
      assert_not_nil alliance.name
      assert_not_nil alliance.id
      assert_not_nil alliance.short_name
      assert_not_nil alliance.member_count
      assert_not_nil alliance.executor_corp_id
      corpsize += alliance.member_corporations.size
    end
    assert_equal 150, corpsize
  end

  def test_sovereignty_clean
    Reve::API.sovereignty_url = XML_BASE + 'sovereignty.xml'
    sovereignties = nil
    assert_nothing_raised do
      sovereignties = @api.sovereignty
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 7, sovereignties.size
    sovereignties.each do |sovereignty|
      assert_instance_of Reve::Classes::Sovereignty, sovereignty
      assert_not_nil sovereignty.system_id
      assert_not_nil sovereignty.constellation_sovereignty
      assert_not_nil sovereignty.system_name
    end
  end

  def test_reftypes_clean
    Reve::API.reftypes_url = XML_BASE + 'reftypes.xml'
    reftypes = nil
    assert_nothing_raised do
      reftypes = @api.ref_types
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 6, reftypes.size
    reftypes.each do |reftype|
      assert_not_nil reftype.id
      assert_not_nil reftype.name
    end
  end
  
  def test_market_orders_clean
    Reve::API.personal_market_orders_url = XML_BASE + 'marketorders.xml'
    orders = nil
    assert_nothing_raised do
      orders = @api.personal_market_orders
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 11, orders.size    
    buys = sells = 0
    orders.each do |order|
      [ :id, :character_id, :station_id, :volume_entered, :volume_remaining, :minimum_volume,
      :order_state, :type_id, :range, :account_key, :duration, :escrow, :price, :bid ].each do |attr|
        assert_not_nil(order.send(attr))
      end
      assert_kind_of Time, order.created_at
      assert [TrueClass, FalseClass].include?(order.bid.class)
      buys  += 1 if ! order.bid
      sells += 1 if   order.bid
      assert_not_equal(0, order.character_id)
    end
    assert_equal 4, buys
    assert_equal 7, sells
  end

  def test_corporate_market_orders_clean
    orders = nil
    assert_nothing_raised do
      orders = @api.corporate_market_orders :url => File.join(XML_BASE,'corporate_market_orders.xml')  
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 1, orders.size    
    buys = sells = 0
    orders.each do |order|
      [ :id, :character_id, :station_id, :volume_entered, :volume_remaining, :minimum_volume,
      :order_state, :type_id, :range, :account_key, :duration, :escrow, :price, :bid ].each do |attr|
        assert_not_nil(order.send(attr))
      end
      assert_kind_of Time, order.created_at
      assert [TrueClass, FalseClass].include?(order.bid.class)
      buys  += 1 if ! order.bid
      sells += 1 if   order.bid        
    end
    assert_equal 1, buys
    assert_equal 0, sells    
  end
  
  def test_corporate_wallet_transactions
    trans = nil
    assert_nothing_raised do
      trans = @api.corporate_wallet_transactions :url => File.join(XML_BASE,'corporate_wallet_transactions.xml')
    end
    assert_equal 1, trans.size
    assert trans.all? { |tran| tran.kind_of?(Reve::Classes::CorporateWalletTransaction) }
    trans.each do |tran|
      [ :created_at, :id, :quantity, :type_name, :type_id, :price, 
        :client_id, :client_name, :character_id, :station_id, :station_name, :type,
        :transaction_for ].each do |attr|
      assert_not_nil(tran.send(attr))
    end
    assert_instance_of(Time, tran.created_at)
    end
  end
  
  def test_corporate_wallet_balance_clean
    balance = nil
    assert_nothing_raised do
      balance = @api.corporate_wallet_balance :url => File.join(XML_BASE, 'corporate_wallet_balance.xml')
    end
    assert balance.all? { |b| b.kind_of?(Reve::Classes::WalletBalance) }
    balance.each do |bal|
      assert_not_nil(bal.account_id)
      assert_not_nil(bal.account_key)
      assert_not_nil(bal.balance)
    end
    assert_equal 18004409.84, balance.select { |b| b.account_key == '1000' }.first.balance
    balance.select { |b| b.account_key != '1000' }.each do |non_tested_account|
      assert_equal 0.00, non_tested_account.balance
    end
  end
  
  def test_corporate_wallet_journal_clean
    journal = nil
    assert_nothing_raised do
      journal = @api.corporate_wallet_journal :url => File.join(XML_BASE,'corporate_wallet_journal.xml')
    end
    assert_equal 2, journal.size
    assert journal.all? { |j| j.kind_of?(Reve::Classes::WalletJournal) }    
    journal.each do |j|
      [ :date, :ref_id, :reftype_id, :owner_name1, :owner_name2, :arg_name1, :amount, :balance, :reason ].each do |attr|
        assert_not_nil(j.send(attr))
      end
    end
  end
  
  def test_corporate_assets_list_clean
    assets = nil
    assert_nothing_raised do
      assets = @api.corporate_assets_list :url => File.join(XML_BASE,'corporate_assets_list.xml')
    end
    assert_equal 2, assets.size
    assert assets.all? { |a| a.kind_of?(Reve::Classes::AssetContainer) }
  end
  
  def test_map_jumps_clean
    Reve::API.map_jumps_url = XML_BASE + 'mapjumps.xml'
    mapjumps = nil
    assert_nothing_raised do
      mapjumps = @api.map_jumps
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 5, mapjumps.size
    mapjumps.each do |jump|
      assert_not_nil jump.system_id
      assert_not_nil jump.jumps
    end
  end
  
  def test_map_kills_clean
    Reve::API.map_kills_url = XML_BASE + 'mapkills.xml'
    mapkills = nil
    assert_nothing_raised do
      mapkills = @api.map_kills
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 4, mapkills.size
    mapkills.each do |kill|
      assert_not_nil kill.system_id
      assert_not_nil kill.faction_kills
      assert_not_nil kill.ship_kills
      assert_not_nil kill.pod_kills
    end
  end

  def test_skill_tree_clean
    Reve::API.skill_tree_url = XML_BASE + 'skilltree.xml'
    skilltrees = nil
    assert_nothing_raised do
      skilltrees = @api.skill_tree
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 2, skilltrees.size
    skilltrees.each do |skill|
      assert_not_nil skill.type_id
      assert_not_nil skill.name
      assert_not_nil skill.rank
      assert_not_nil skill.description
      skill.bonuses.each do |bonus|
        assert_kind_of Reve::Classes::SkillBonus, bonus
      end
      skill.attribs.each do |attrib|
        assert_kind_of Reve::Classes::RequiredAttribute, attrib
      end
      skill.required_skills.each do |req|
        assert_kind_of Reve::Classes::SkillRequirement, req
      end
    end
  end

  def test_wallet_balance_clean
    Reve::API.personal_wallet_balance_url = XML_BASE + 'wallet_balance.xml'
    balance = nil
    assert_nothing_raised do
      balance = @api.personal_wallet_balance(:characterid => 1)
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 7, balance.size
    balance.each do |bal|
      assert_not_nil bal.account_id
      assert_not_nil bal.account_key
      assert_not_nil bal.balance
    end
  end

  def test_wallet_transactions_clean
    Reve::API.personal_wallet_trans_url = XML_BASE + 'market_transactions.xml'
    trans = nil
    assert_nothing_raised do
      trans = @api.personal_wallet_transactions(:characterid => 1)
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_instance_of Reve::Classes::PersonalWalletTransaction, trans.first
    assert_equal 9, trans.size
    trans.each do |t|
      assert_not_nil t.created_at
      assert_not_nil t.id
      assert_not_nil t.quantity
      assert_not_nil t.type_name
      assert_not_nil t.type_id
      assert_not_nil t.price
      assert_not_nil t.client_name
      assert_not_nil t.station_id
      assert_not_nil t.station_name
      assert_not_nil t.type
    end
  end

  def test_wallet_journal_clean
    Reve::API.personal_wallet_journal_url = XML_BASE + 'wallet_journal.xml'
    journal = nil
    assert_nothing_raised do
      journal = @api.personal_wallet_journal(:characterid => 1)
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 8, journal.size
    journal.each do |j|
      assert_not_nil j.date
      assert_not_nil j.ref_id
      assert_not_nil j.reftype_id
      assert_not_nil j.owner_name1
      assert_not_nil j.owner_name2
      assert_not_nil j.arg_name1
      assert_not_nil j.amount
      assert_not_nil j.balance
      assert_not_nil j.reason
    end
  end

  def test_member_tracking_clean
    Reve::API.member_tracking_url = XML_BASE + 'member_tracking.xml'
    members = nil
    assert_nothing_raised do
      members = @api.member_tracking(:characterid => 1)
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 2, members.size
    members.each do |member|
      assert_not_nil member.character_id
      assert_not_nil member.character_name
      assert_not_nil member.start_time
      assert_not_nil member.base_id
      assert_not_nil member.base
      assert_not_nil member.title
      assert_not_nil member.logon_time
      assert_not_nil member.logoff_time
      assert_not_nil member.location_id
      assert_not_nil member.location
      assert_not_nil member.ship_type_id
      assert_not_nil member.ship_type
      assert_not_nil member.roles
      assert_not_nil member.grantable_roles
    end
  end
  
  def test_member_corporation_sheet_clean
    Reve::API.corporation_sheet_url = XML_BASE + 'corporation_sheet.xml'
    sheet = nil
    assert_nothing_raised do
      sheet = @api.corporation_sheet
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 7, sheet.divisions.size
    assert_equal 7, sheet.wallet_divisions.size
  end
  
  def test_nonmember_corporation_sheet_clean
    Reve::API.corporation_sheet_url = XML_BASE + 'nonmember_corpsheet.xml'
    sheet = nil
    assert_nothing_raised do
      sheet = @api.corporation_sheet :corporationid => 134300597
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal 0, sheet.divisions.size
    assert_equal 0, sheet.wallet_divisions.size
  end

  def test_no_skill_in_training_clean
#    Reve::API.training_skill_url = XML_BASE + 'skill_in_training-none.xml'
    skill = nil
    assert_nothing_raised do
      skill = @api.skill_in_training(:characterid => 1, :url => XML_BASE + 'skill_in_training-none.xml')
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert_equal false, skill.skill_in_training
  end

=begin
    # Tests Reve::API#get_xml's segment that fetches from http
    def test_no_skill_in_training_clean_from_svn
      skill = nil
      assert_nothing_raised do
        skill = @api.skill_in_training(:characterid => 123, :url => URI.parse('http://svn.crudvision.com/reve/trunk/test/xml/skill_in_training-none.xml'))
      end
      assert_not_nil @api.last_hash
      assert_kind_of Time, @api.cached_until
      assert_equal false, skill.skill_in_training
    end
=end

  def test_amarr_titan_skill_in_training_clean
    Reve::API.training_skill_url = XML_BASE + 'skill_in_training-amarr-titan.xml'
    skill = nil
    assert_nothing_raised do
      skill = @api.skill_in_training(:characerid => 1)
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    assert skill.skill_in_training
    assert_not_nil skill.start_time
    assert_not_nil skill.type_id
    assert_not_nil skill.end_time
    assert_not_nil skill.to_level
    assert_not_nil skill.start_sp
    assert_not_nil skill.end_sp
  end

  def test_skill_queue_clean
    Reve::API.skill_queue_url = XML_BASE + 'skill_queue.xml'
    queue = nil
    assert_nothing_raised do
      queue = @api.skill_queue(:characerid => 1)
    end
    assert_kind_of(Reve::Classes::QueuedSkill, queue.first)
    assert_not_nil queue.first.queue_position
    assert_not_nil queue.first.start_time
    assert_not_nil queue.first.type_id
    assert_not_nil queue.first.end_time
    assert_not_nil queue.first.to_level
    assert_not_nil queue.first.start_sp
    assert_not_nil queue.first.end_sp
    assert_equal 9, queue.length
    Reve::API.skill_queue_url = XML_BASE + 'skill_queue-paused.xml'
    queue = nil
    assert_nothing_raised do
      queue = @api.skill_queue(:characerid => 1)
    end
    assert_kind_of(Reve::Classes::QueuedSkill, queue.first)
    assert_nil queue.first.start_time
    assert_nil queue.first.end_time
  end

  def test_corporate_medals
    Reve::API.corporate_medals_url = XML_BASE + 'corp_medals.xml'
    medals = nil
    assert_nothing_raised do
      medals = @api.corporate_medals
    end
    assert_equal(12, medals.size)
    medals.each do |medal|
      assert_kind_of(Reve::Classes::CorporateMedal, medal)
      assert_kind_of(Numeric, medal.id)
      assert_kind_of(NilClass, medal.issued_at) # Doesn't exist for this class, look at created_at
      assert_kind_of(Time, medal.created_at)
      assert_kind_of(String, medal.description)
      assert_kind_of(Numeric, medal.creator_id)
      assert_kind_of(String, medal.title)
    end
  end
  
  def test_corporate_member_medals
    Reve::API.corp_member_medals_url = XML_BASE + 'corp_member_medals.xml'
    medals = nil
    assert_nothing_raised do
      medals = @api.corporate_member_medals
    end
    assert_equal(9, medals.size)
    medals.each do |medal|
      assert_kind_of(Reve::Classes::CorporateMemberMedal, medal)
      assert_kind_of(Numeric, medal.id)
      assert_kind_of(Time, medal.issued_at)
      assert_kind_of(Numeric, medal.character_id)
      assert_kind_of(String, medal.reason)
      assert_kind_of(Numeric, medal.issuer_id)
      assert_kind_of(String, medal.status)
      assert medal.is_public?
      assert ! medal.is_private?
    end
  end
  
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
  
  def test_server_status
    Reve::API.server_status_url = XML_BASE + 'server_status.xml'
    status = nil
    assert_nothing_raised do
      status = @api.server_status
    end
    assert_kind_of(Reve::Classes::ServerStatus, status)
    assert_equal(34444, status.players)
    assert status.open?
    assert status.open
  end
  
  def test_character_medals
    Reve::API.character_medals_url = XML_BASE + 'char_medals.xml'
    obj = nil
    assert_nothing_raised do
      obj = @api.character_medals
    end
    assert_kind_of(Reve::Classes::CharacterMedals, obj)
    assert_equal(1, obj.current_corporation.size)
    assert obj.other_corporation.empty?
    obj.current_corporation.each do |medal|
      assert_kind_of(Reve::Classes::CharacterMedal, medal)
      assert_kind_of(Numeric, medal.id)
      assert_kind_of(Time, medal.issued_at)
      assert_kind_of(String, medal.reason)
      assert_kind_of(Numeric, medal.issuer_id)
      assert_kind_of(String, medal.status)
      assert medal.is_public?
      assert ! medal.is_private?      
    end   
    
  end

  def test_certificate_sheet
    Reve::API.certificate_tree_url = XML_BASE + 'certificate_tree.xml'
    tree = nil
    assert_nothing_raised do
      tree = @api.certificate_tree
    end
    # going to hell
    assert_kind_of(Reve::Classes::CertificateTree, tree)
    assert_equal(1, tree.categories.size)
    assert tree.categories.all? { |cat| cat.kind_of?(Reve::Classes::CertificateCategory) }
    assert tree.categories.all? { |cat| cat.id.kind_of?(Numeric) && cat.name.kind_of?(String) }
    assert_equal(6, tree.categories.first.classes.size) # just 1 category
    assert tree.categories.first.classes.all? { |klass| klass.kind_of?(Reve::Classes::CertificateClass) }
    assert tree.categories.first.classes.all? { |klass| klass.id.kind_of?(Numeric) && klass.name.kind_of?(String) }
    assert tree.categories.first.classes.collect { |klass| klass.certificates }.flatten.all? { |cert| cert.id.kind_of?(Numeric) && cert.grade.kind_of?(Numeric) && cert.corporation_id.kind_of?(Numeric) && cert.description.kind_of?(String) }
    assert_equal(20, tree.categories.first.classes.collect { |klass| klass.certificates }.flatten.size) 
    assert_equal(54, tree.categories.first.classes.collect { |klass| klass.certificates }.flatten.collect { |cert| cert.required_skills }.flatten.size)
    assert tree.categories.first.classes.collect { |klass| klass.certificates }.flatten.collect { |cert| cert.required_skills }.flatten.all? { |req| req.id.kind_of?(Numeric) && req.level.kind_of?(Numeric) }
    assert_equal(29, tree.categories.first.classes.collect { |klass| klass.certificates }.flatten.collect { |cert| cert.required_certificates }.flatten.size)
    assert tree.categories.first.classes.collect { |klass| klass.certificates }.flatten.collect { |cert| cert.required_certificates }.flatten.all? { |req| req.id.kind_of?(Numeric) && req.grade.kind_of?(Numeric) }
  end

  def test_character_sheet_clean
    Reve::API.character_sheet_url = XML_BASE + 'character_sheet.xml'
    sheet = nil
    assert_nothing_raised do
      sheet = @api.character_sheet(:characterid => 1)
    end
    assert_not_nil @api.last_hash
    assert_kind_of Time, @api.cached_until
    
    assert_not_nil sheet.name
    assert_not_nil sheet.race
    assert_not_nil sheet.bloodline
    assert_not_nil sheet.gender
    assert_not_nil sheet.id
    assert_not_nil sheet.corporation_name
    assert_not_nil sheet.corporation_id
    assert_not_nil sheet.balance

    assert_not_nil sheet.intelligence
    assert_not_nil sheet.memory
    assert_not_nil sheet.charisma
    assert_not_nil sheet.perception
    assert_not_nil sheet.willpower

    assert_equal 5, sheet.enhancers.size, "Implant size mismatch"
    sheet.enhancers.each do |enhancer|
      assert_kind_of Reve::Classes::AttributeEnhancer, enhancer
    end
    assert_equal 44842126, sheet.skills.inject(0) { |sum,s| sum += s.skillpoints }, "Skillpoint total mismatch"

    sheet.skills.each do |skill|
      assert_kind_of Reve::Classes::Skill, skill
    end
    assert_equal(57, sheet.certificate_ids.size,"Certificate ID size mismatch")
    assert sheet.certificate_ids.all? { |cid| cid.kind_of?(Fixnum) }
    
    # role aliases
    assert ! sheet.corporate_roles_at_hq.empty?
    assert ! sheet.corporate_roles.empty?
    assert ! sheet.corporate_roles_at_base.empty?
    assert ! sheet.corporate_roles_at_other.empty?
    # role proper methods
    assert ! sheet.corporationRolesAtHQ.empty?
    assert ! sheet.corporationRoles.empty?
    assert ! sheet.corporationRolesAtBase.empty?
    assert ! sheet.corporationRolesAtOther.empty?
    
    [ :corporate_roles_at_hq, :corporate_roles, :corporate_roles_at_base, :corporate_roles_at_other ].each do |role_kind|
      r_ary = sheet.send(role_kind) 
      assert r_ary.all? { |r| r.kind_of?(Reve::Classes::CorporateRole) }
      assert r_ary.all? { |r| r.name.kind_of?(String) }
      assert r_ary.all? { |r| r.id.kind_of?(Numeric) }
    end
    
    assert ! sheet.corporate_titles.empty?
    assert sheet.corporate_titles.all? { |t| t.kind_of?(Reve::Classes::CorporateTitle) }
    assert sheet.corporate_titles.all? { |t| t.name.kind_of?(String) }
    assert sheet.corporate_titles.all? { |t| t.id.kind_of?(Numeric) }
    
    
    
  end
  
  def test_personal_notifications
    Reve::API.personal_notification_url = XML_BASE + 'notifications.xml'
    notifications = nil
    assert_nothing_raised do
      notifications = @api.personal_notifications(:characterid => 1)
    end
    assert_equal 2, notifications.length
    assert_equal Reve::Classes::Notification, notifications.first.class
    assert_equal 200076684, notifications.first.sender_id
    assert_equal 16, notifications.first.notification_type_id
    assert_equal Time.parse('2009-12-02 10:54:00 UTC'), notifications.first.send_date
  end

  def test_personal_mailing_lists
    Reve::API.personal_mailing_lists_url = XML_BASE + 'mailing_lists.xml'
    lists = nil
    assert_nothing_raised do
      lists = @api.personal_mailing_lists(:characterid => 1)
    end
    assert_equal 3, lists.length
    assert_equal Reve::Classes::MailingList, lists.first.class
    assert_equal 128250439, lists.first.id
    assert_equal 'EVETycoonMail', lists.first.name
    assert_equal 141157801, lists.last.id
  end

  def test_personal_mail_messages
    Reve::API.personal_mail_messages_url = XML_BASE + 'mail_messages.xml'
    mails = nil
    assert_nothing_raised do
      mails = @api.personal_mail_messages(:characterid => 1)
    end
    assert_equal 5, mails.length
    assert_equal Reve::Classes::MailMessage, mails.first.class
    # Corp Mail
    assert_equal 1, mails.first.sender_id
    assert_equal Time.parse('2009-12-01 01:04:00 UTC'), mails.first.send_date
    assert_equal "Corp mail", mails.first.title
    assert_equal 4, mails.first.to_corp_or_alliance_id
    assert_equal nil, mails.first.to_character_ids
    assert_equal nil, mails.first.to_list_ids
    assert_equal true, mails.first.read
    # Personal Mail
    assert_equal nil, mails[1].to_corp_or_alliance_id
    assert_equal [5], mails[1].to_character_ids
    assert_equal nil, mails[1].to_list_ids
    # list Mail
    assert_equal nil, mails[2].to_corp_or_alliance_id
    assert_equal nil, mails[2].to_character_ids
    assert_equal [128250439], mails[2].to_list_ids
    assert_equal false, mails[2].read
    # multi personal
    assert_equal [5,6,7], mails[3].to_character_ids
    # multi list
    assert_equal [128250439,141157801], mails[4].to_list_ids
  end

  # Can we reassign a URL?
  def test_assignment
    assert_nothing_raised do
      Reve::API.character_sheet_url = "hello"
    end
  end

  # Laziness pays off I hope
  def test_all_raise_errors
    Dir.glob(File.join(XML_BASE,'errors','*.xml')).each do |file|
      # Using begin/rescue/assert here because assert_raise doesn't work with.
      # the exception superclass.
      begin
        @api.send(:check_exception,(File.open(file).read))
      rescue Exception => e
        assert e.kind_of?(Reve::Exceptions::ReveError)
      end
    end
  end

  def test_get_xml_from_filesystem
    xmldoc = @api.send(:get_xml, File.join(XML_BASE, 'skill_in_training-none.xml'), {} )
    assert_equal File.open(File.join(XML_BASE, 'skill_in_training-none.xml')).read, xmldoc
  end
  
=begin
    def test_get_xml_from_web
      xmldoc = @api.send(:get_xml, 'http://svn.crudvision.com/reve/trunk/test/xml/skill_in_training-none.xml', {} )
      assert_equal File.open(File.join(XML_BASE, 'skill_in_training-none.xml')).read, xmldoc
    end
=end
  
  def test_get_xml_from_filesystem_missing_file
    assert_raise Errno::ENOENT do
      xmldoc = @api.send(:get_xml, File.join(XML_BASE,rand.to_s), {} )
    end    
  end
=begin  
  # if this starts to fail make sure the 404 ErrorDocument includes '404 Not Found'
  def test_get_xml_from_web_missing_file
    begin
      xmldoc = @api.send(:get_xml, 'http://svn.crudvision.com/reve/trunk/test/' + rand.to_s, {} )
    rescue Exception => e
      assert e.kind_of?(Reve::Exceptions::ReveNetworkStatusException)
      assert e.message.include?('404 Not Found')
    end    
  end
=end

  def test_format_url_request_one_arg
    req = @api.send(:format_url_request, { :a => "Hello" })
    assert_equal "?a=Hello", req
  end
  
  def test_format_url_request_two_args
    req = @api.send(:format_url_request, { :a => "Hello", :world => "b" })
    assert_equal "?a=Hello&world=b", req
  end
  
  def test_format_url_request_nil_value
    req = @api.send(:format_url_request, { :a => "Hello", :world => nil })
    assert_equal "?a=Hello", req  
  end 
  
  # make sure we can make a Time object
  def test_to_time_method
    str = "2008-01-23 10:32:20"
    real = Time.utc(2008,01,23,10,32,20)
    time = nil
    assert_nothing_raised do
      time  = str.to_time
    end
    assert_kind_of Time,time
    assert_equal real,time
  end
  
  # It's useful to know the version and we'll stick it in the user agent
  # now as well.
  def test_reve_version
    # Path to Reve version is ../VERSION. We rely on File.read here and in the
    # class so it's kind of crummy.
    version = File.read(File.join(File.dirname(__FILE__),'../','VERSION'))
    assert_equal(@api.reve_version, version)
    assert_equal("Reve v#{version}; http://github.com/lisa/reve", @api.http_user_agent)
  end
  
  # no need to test corporate cos they're the same.
  # TODO: Test with nested losses
  def kills_cleanly(meth = :personal_kills,url = File.join(XML_BASE,'kills.xml'))
    kills = nil
    assert_nothing_raised do
      kills = @api.send(meth,{:url =>url})
    end
    assert_equal 25, kills.size
    assert_equal 25, kills.collect { |k| k.victim.name }.compact.length # i should have 10 good victim names to match with 10 kills
    
    # Process the Kills here to get the number of "Contained Losses" - KillLoss that are contained within another
    # KillLoss (like a Giant Secure Container); there should only be one contained loss and should be 
    # 64 losses (including the contained_losses)
    losses = kills.collect { |k| k.losses }.flatten
    assert_equal 292, losses.size
    contained_losses = losses.collect { |loss| loss.contained_losses  }.flatten
    assert_equal 0, contained_losses.size

    attacker_names = kills.collect { |k| k.attackers.collect { |a| a.name } }.flatten
    assert_equal 98, attacker_names.size # total of 25 attackers (24 players + 1 NPC)
    assert_equal 2, attacker_names.grep(nil).size # npc exists once
    assert_equal 96, attacker_names.compact.length # 24 player attackers

    assert_kind_of Integer, kills.first.victim.faction_id
    assert_kind_of String, kills.first.victim.faction_name

    assert_kind_of String, kills.first.attackers.first.faction_name

    kills.each do |kill|
      assert_kind_of Integer, kill.id
      assert_kind_of Integer, kill.system_id

      assert_kind_of Time, kill.created_at
      assert_nil kill.moon_id # the ones in the kills.xml are all nil
      kill.losses.each do |loss|
        assert_not_nil(loss.type_id)
        assert_not_nil(loss.flag)
        assert_not_nil(loss.quantity_dropped)
        assert_not_nil(loss.quantity_destroyed)
        loss.contained_losses.each do |closs|
          assert_not_nil(closs.type_id)
          assert_not_nil(closs.flag)
          assert_not_nil(closs.quantity_dropped)
          assert_not_nil(closs.quantity_destroyed)
        end
      end
    end
  end

  #### All tests above this method.
  protected
  def get_api(userid = nil, apikey = nil, charid = nil)
    api = Reve::API.new(userid, apikey, charid)
    api.save_path = nil
    api
  end
end
