#--
# Code copyright Lisa Seelye, 2007-2010. www.crudvision.com
# Contributors at: http://github.com/lisa/reve/contributors
# This library is licensed under the terms of the MIT license. For full text
# see the LICENSE file distributed with this package.
#++

begin
  require 'hpricot'
rescue LoadError
  require 'rubygems'
  require 'hpricot'
end
require 'net/https'
require 'uri'
require 'cgi'
require 'digest'
require 'fileutils'
require 'time'

$:.unshift(File.dirname(__FILE__)) unless $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'reve/exceptions'
require 'reve/extensions'
require 'reve/classes'
require 'reve/processing_helpers'


module Reve
  # API Class.
  # Basic Usage:
  # api = Reve::API.new('my_keyID', 'my_vCode')
  # alliances = api.alliances # Returns an array of Reve::Classes::Alliance
  #
  # api.personal_wallet_blanace(:characterid => 892008733) # Returns an array of
  # Reve::Classes::WalletBalance. Note that the CharacterID Number is required
  # here.
  #
  # api.sovereignty :just_hash => true # Returns the hash for this call with no
  # Alliance data with it.
  #
  # As of Revision 22 (28 August 2007) all API calls take a parameter, 
  # :just_hash, to just get the hash that represents that particular API call;
  # No data related to the call is returned if :just_hash is present
  # 
  # All API methods have the functionality to read XML from an arbitrary location. This could be another webserver, or a XML file on disk.
  # To use this pass the hash option :url => +location+ where +location+ is a String or URI class. See format_url_request documentation for more details.
  class API
    BASE_URL = 'https://api.eveonline.com'
    
    @@characters_url                  = BASE_URL + '/account/Characters.xml.aspx'
    @@account_status_url              = BASE_URL + '/account/AccountStatus.xml.aspx'

    @@research_url                    = BASE_URL + '/char/Research.xml.aspx'
    @@contracts_url                   = BASE_URL + '/char/Contracts.xml.aspx'
    @@personal_notification_url       = BASE_URL + '/char/Notifications.xml.aspx'
    @@personal_mailing_lists_url      = BASE_URL + '/char/mailinglists.xml.aspx'
    @@personal_mail_messages_url      = BASE_URL + '/char/MailMessages.xml.aspx'
    @@personal_mail_message_bodies_url= BASE_URL + '/char/MailBodies.xml.aspx'
    @@personal_contacts_url           = BASE_URL + '/char/ContactList.xml.aspx'
    @@personal_wallet_balance_url     = BASE_URL + '/char/AccountBalance.xml.aspx' 
    @@personal_wallet_trans_url       = BASE_URL + '/char/WalletTransactions.xml.aspx'
    @@personal_wallet_journal_url     = BASE_URL + '/char/WalletJournal.xml.aspx'
    @@training_skill_url              = BASE_URL + '/char/SkillInTraining.xml.aspx'
    @@skill_queue_url                 = BASE_URL + '/char/SkillQueue.xml.aspx'
    @@character_sheet_url             = BASE_URL + '/char/CharacterSheet.xml.aspx'
    @@personal_market_orders_url      = BASE_URL + '/char/MarketOrders.xml.aspx'
    @@personal_industry_jobs_url      = BASE_URL + '/char/IndustryJobs.xml.aspx'
    @@personal_assets_url             = BASE_URL + '/char/AssetList.xml.aspx'
    @@personal_kills_url              = BASE_URL + '/char/KillLog.xml.aspx'
    @@personal_faction_war_stats_url  = BASE_URL + '/char/FacWarStats.xml.aspx'
    @@character_medals_url            = BASE_URL + '/char/Medals.xml.aspx'
    @@upcoming_calendar_events_url    = BASE_URL + '/char/UpcomingCalendarEvents.xml.aspx'

    @@member_tracking_url             = BASE_URL + '/corp/MemberTracking.xml.aspx'
    @@corporate_wallet_balance_url    = BASE_URL + '/corp/AccountBalance.xml.aspx'
    @@corporate_wallet_trans_url      = BASE_URL + '/corp/WalletTransactions.xml.aspx'
    @@corporate_wallet_journal_url    = BASE_URL + '/corp/WalletJournal.xml.aspx'
    @@starbases_url                   = BASE_URL + '/corp/StarbaseList.xml.aspx'
    @@starbasedetail_url              = BASE_URL + '/corp/StarbaseDetail.xml.aspx'
    @@corporation_sheet_url           = BASE_URL + '/corp/CorporationSheet.xml.aspx'
    @@corporation_member_security_url = BASE_URL + '/corp/MemberSecurity.xml.aspx'
    @@corporate_market_orders_url     = BASE_URL + '/corp/MarketOrders.xml.aspx'
    @@corporate_industry_jobs_url     = BASE_URL + '/corp/IndustryJobs.xml.aspx'
    @@corporate_assets_url            = BASE_URL + '/corp/AssetList.xml.aspx'
    @@corporate_kills_url             = BASE_URL + '/corp/KillLog.xml.aspx'
    @@corporate_faction_war_stats_url = BASE_URL + '/corp/FacWarStats.xml.aspx'
    @@corporate_medals_url            = BASE_URL + '/corp/Medals.xml.aspx'
    @@corp_member_medals_url          = BASE_URL + '/corp/MemberMedals.xml.aspx'
    @@corporate_contacts_url          = BASE_URL + '/corp/ContactList.xml.aspx'

    @@alliances_url                   = BASE_URL + '/eve/AllianceList.xml.aspx'
    @@reftypes_url                    = BASE_URL + '/eve/RefTypes.xml.aspx'
    @@skill_tree_url                  = BASE_URL + '/eve/SkillTree.xml.aspx'
    @@conqurable_outposts_url         = BASE_URL + '/eve/ConquerableStationList.xml.aspx'
    @@errors_url                      = BASE_URL + '/eve/ErrorList.xml.aspx'
    @@character_id_url                = BASE_URL + '/eve/CharacterID.xml.aspx'   # ?names=CCP%20Garthagk
    @@general_faction_war_stats_url   = BASE_URL + '/eve/FacWarStats.xml.aspx'
    @@top_faction_war_stats_url       = BASE_URL + '/eve/FacWarTopStats.xml.aspx'
    @@certificate_tree_url            = BASE_URL + '/eve/CertificateTree.xml.aspx'
    @@character_name_url              = BASE_URL + '/eve/CharacterName.xml.aspx' # ?ids=797400947
    @@character_info_url              = BASE_URL + '/eve/CharacterInfo.xml.aspx'
    
    @@sovereignty_url                 = BASE_URL + '/map/Sovereignty.xml.aspx'
    @@map_jumps_url                   = BASE_URL + '/map/Jumps.xml.aspx'
    @@map_kills_url                   = BASE_URL + '/map/Kills.xml.aspx'
    @@faction_war_occupancy_url       = BASE_URL + '/map/FacWarSystems.xml.aspx'
    
    @@server_status_url               = BASE_URL + '/Server/ServerStatus.xml.aspx'    
    
    cattr_accessor :character_sheet_url, :training_skill_url, :characters_url, :personal_wallet_journal_url,
                   :corporate_wallet_journal_url, :personal_wallet_trans_url, :corporate_wallet_trans_url,
                   :personal_wallet_balance_url, :corporate_wallet_balance_url, :member_tracking_url,
                   :skill_tree_url, :reftypes_url, :sovereignty_url, :alliances_url, :starbases_url,
                   :starbasedetail_url, :conqurable_outposts_url, :corporation_sheet_url, :map_jumps_url,
                   :map_kills_url, :personal_market_orders_url, :corporate_market_orders_url,
                   :personal_industry_jobs_url, :corporate_industry_jobs_url, :personal_assets_url,
                   :corporate_assets_url, :personal_kills_url, :corporate_kills_url,
                   :personal_faction_war_stats_url, :corporate_faction_war_stats_url,
                   :general_faction_war_stats_url, :top_faction_war_stats_url, :faction_war_occupancy_url,
                   :certificate_tree_url, :character_medals_url, :corporate_medals_url, 
                   :corp_member_medals_url, :server_status_url, :skill_queue_url, :corporation_member_security_url,
                   :personal_notification_url, :personal_mailing_lists_url, :personal_mail_messages_url,
                   :personal_mail_message_bodies_url, :research_url, :personal_contacts_url, :corporate_contacts_url,
                   :account_status_url, :character_info_url, :upcoming_calendar_events_url

    attr_accessor :key, :keyid, :cak, :charid
    alias :userid :keyid
    alias :userid= :keyid=
    attr_accessor :http_user_agent, :save_path, :timeout
    attr_reader :current_time, :cached_until, :last_hash, :last_xml, :reve_version
    
    # Create a new API instance.
    # current_time and cached_until are meaningful only for the LAST call made.
    # Expects:
    # * keyid ( Integer | String ) - Your Key ID (or legacy key UserID)
    # * key ( String ) - Your API key verification code (or legacy API Key)
    # * charid ( Integer | String ) - Default characterID for calls requiring it.
    #
    # If you are using legacy key ids, you must explicitly set the
    # cak attribute on the returned API instance to false.
    #
    # NOTE: All values passed to the constructor are typecasted to a String for safety.
    def initialize(keyid = "", key = "", charid = "")
      @keyid  = (keyid || "").to_s
      @key    = (key    || "").to_s
      @charid = (charid || "").to_s
      @cak    = true
      @save_path = nil
      
      @max_tries = 3
      @timeout = 20

      @current_time = nil
      @cached_until = nil
      @last_hash = nil
      @last_xml  = nil
      @reve_version = File.read(File.join(File.dirname(__FILE__),'../','VERSION')).chomp
      @http_user_agent = "Reve v#{@reve_version}; http://github.com/lisa/reve"
    end
    # Save XML to this directory with the format:
    # :save_path/:keyid/:method/:expires_at_in_unixtime.xml
    # eg: ./xml/12345/characters/1200228878.xml
    # or: ./xml/alliances/1200228878.xml
    # If @save_path is nil then XML is not saved.
    def save_path=(p)
      @save_path = p
    end
    
    # Get the server status of Tranquility as a Reve::Classes::ServerStatus 
    # object.
    # See Also: Reve::Classes::ServerStatus
    def server_status(opts = {})
      args = postfields(opts)
      h = compute_hash(  opts.merge(:url => @@server_status_url) )
      return h if h
      xml = process_query(nil,opts[:url] || @@server_status_url,true,opts)
      Reve::Classes::ServerStatus.new(
        xml.search("/eveapi/result/serverOpen/").first.to_s,
        xml.search("/eveapi/result/onlinePlayers/").first.to_s
      )
    end
    
    # Convert a list of names to their ids.
    # Expects a Hash as a parameter with these keys:
    # * names ( Array ) - An Array of Names to fetch the IDs of.
    # See Also: character_name, Reve::Classes::Character, character_sheet
    def names_to_ids(opts = {} )
      names = opts[:names] || []
      return [] if names.empty? # No names were passed.
      opts[:names] = names.join(',')
      args = postfields(opts)
      h = compute_hash(  opts.merge(:url => @@character_id_url) )
      return h if h
      xml = process_query(nil,opts[:url] || @@character_id_url, true,opts)
      ret = []
      xml.search("//rowset/row").each do |elem|
        ret << Reve::Classes::Character.new(elem)
      end
      ret
    end
    
    alias_method  :character_id, :names_to_ids
    
    # Convert  ids to Character names.
    # Expects a Hash as a parameter with these keys:
    # * ids ( Array ) - An Array of Character IDs to fetch the names of.
    # See Also: character_name, Reve::Classes::Character, character_sheet

    def ids_to_names(opts = {})
      ids = opts[:ids] || []
      return [] if ids.empty? #No ids where passed
      opts[:ids] = ids.join(',')
      args = postfields(opts)
      h = compute_hash(  opts.merge(:url => @@character_name_url) )
      return h if h
      xml = process_query(nil,opts[:url] || @@character_name_url, true,opts)
      ret = []
        xml.search("//rowset/row").each do |elem|
          ret << Reve::Classes::Character.new(elem)
        end
        ret
      end      
    
    alias_method :character_name, :ids_to_names
    
    # Return a list of Alliances and member Corporations from
    # http://api.eve-online.com/eve/AllianceList.xml.aspx
    # Use the corporation_sheet method to get information for each member
    # Corporation
    # See also: Reve::Classes::Alliance, Reve::Classes::Corporation and
    # corporation_sheet
    def alliances(opts = {})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@alliances_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@alliances_url,true,args)
      alliances = []
      xml.search("/eveapi/result/rowset[@name='alliances']/row").each do |alliance|
        alliance_obj = Reve::Classes::Alliance.new(alliance)
        alliance.search("rowset[@name='memberCorporations']/row").each do |corporation|
          alliance_obj.member_corporations << Reve::Classes::Corporation.new(corporation)
        end
        alliances << alliance_obj
      end
      alliances
    end
    
    # Returns a list of the number of jumps for each system. If there are no
    # jumps for a system it will not be included. See also Reve::Classes::MapJump
    def map_jumps(opts = {})
      compute_hash(  opts.merge(:url => @@map_jumps_url) ) ||
        process_query(Reve::Classes::MapJump,opts[:url] || @@map_jumps_url,false)
    end
    
    # Returns a list of the number of kills for each system. If there are no
    # kills for a system it will not be included. See also Reve::Classes::MapKill
    def map_kills(opts = {})
      compute_hash(  opts.merge(:url => @@map_kills_url) ) ||
        process_query(Reve::Classes::MapKill,opts[:url] || @@map_kills_url,false)
    end
    
    # Returns a list of API Errors
    def errors(opts = {})
      compute_hash(  opts.merge(:url => @@errors_url) ) || 
        process_query(Reve::Classes::APIError,opts[:url] || @@errors_url,false)
    end
    
    # Returns the Sovereignty list from
    # http://api.eve-online.com/map/Sovereignty.xml.aspx
    # See also: Reve::Classes::Sovereignty
    def sovereignty(opts = {})
      compute_hash(  opts.merge(:url => @@sovereignty_url) ) || 
        process_query(Reve::Classes::Sovereignty,opts[:url] || @@sovereignty_url,false)
    end

    # Returns a RefType list (whatever they are) from
    # http://api.eve-online.com/eve/RefTypes.xml.aspx
    # See also: Reve::Classes::RefType
    def ref_types(opts = {})
      compute_hash(  opts.merge(:url => @@reftypes_url) ) || 
          process_query(Reve::Classes::RefType,opts[:url] || @@reftypes_url,false)
    end

    # Returns a list of ConqurableStations and outposts from
    # http://api.eve-online.com/eve/ConquerableStationList.xml.aspx
    # See also: Reve::Classes::ConqurableStation
    def conquerable_stations(opts = {})
      compute_hash(  opts.merge(:url => @@conqurable_outposts_url) ) ||
          process_query(Reve::Classes::ConquerableStation, opts[:url] || @@conqurable_outposts_url, false)
    end
    
    alias_method :conqurable_stations, :conquerable_stations
    
    # Returns a list of Reve::Classes::MarketOrder objects for market orders that are up
    # Pass the characterid of the Character to check for
    def personal_market_orders(opts = {:characterid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_market_orders_url))
      return h if h
      process_query(Reve::Classes::PersonalMarketOrder, opts[:url] || @@personal_market_orders_url, false, args)
    end
    
    # Returns a list of Reve::Classes::MarketOrder objects for market orders that are up on behalf of a Corporation
    # Pass the characterid of the Character of whose corporation to check for
    def corporate_market_orders(opts = {:characterid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporate_market_orders_url))
      return h if h
      process_query(Reve::Classes::CorporateMarketOrder, opts[:url] || @@corporate_market_orders_url, false, args)
    end
    
    # Returns a list of Reve::Classes::PersonalIndustryJob objects.
    def personal_industry_jobs(opts = {:characterid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_industry_jobs_url))
      return h if h
      process_query(Reve::Classes::PersonalIndustryJob, opts[:url] || @@personal_industry_jobs_url,false,args)
    end
    
    # Returns a list of Reve::Classes::CorporateIndustryJob objects.
    def corporate_industry_jobs(opts = {:characterid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporate_industry_jobs_url))
      return h if h
      process_query(Reve::Classes::CorporateIndustryJob, opts[:url] || @@corporate_industry_jobs_url,false,args)
    end
    
    # Returns a list of Reve::Classes::PersonalContact objects.
    def personal_contacts(opts = {:characterid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_contacts_url))
      return h if h
      process_query(Reve::Classes::PersonalContact, opts[:url] || @@personal_contacts_url,false,args)
    end
    
    # Returns a list of Reve::Classes::CorporateContact objects.
    def corporate_contacts(opts = {:characterid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporate_contacts_url))
      return h if h
      xml = process_query(nil, opts[:url] || @@corporate_contacts_url,true,args)
      contacts = []
      xml.search("/eveapi/result/rowset[@name='corporateContactList']/row").each do |corporate|
        contacts << Reve::Classes::CorporateContact.new(corporate)
      end
      xml.search("/eveapi/result/rowset[@name='allianceContactList']/row").each do |alliance|
        contacts << Reve::Classes::AllianceContact.new(alliance)
      end
      contacts
    end
        
    # Returns the SkillTree from
    # http://api.eve-online.com/eve/SkillTree.xml.aspx
    # See also: Reve::Classes::SkillTree
    # NOTE: This doesn't actually return a 'tree' yet.
    def skill_tree(opts = {})
      h = compute_hash(opts.merge(:url => @@skill_tree_url) )
      return h if h
      doc = process_query(nil,opts[:url] || @@skill_tree_url,true)
      skills = []
      (doc/'rowset[@name=skills]/row').each do |skill|
        name = skill['typeName']
        type_id = skill['typeID']
        group_id = skill['groupID']
        rank = (skill/:rank).inner_html
        desc = (skill/:description).inner_html
        required_skills = []
        reqs = (skill/'rowset@name=[requiredskills]/row')
        reqs.each do |required|
          next if required.kind_of? Hpricot::Text # why is this needed? Why is this returned? How can I only get stuff with typeid and skilllevel?
          required_skills << Reve::Classes::SkillRequirement.new(required) if required['typeID'] && required['skillLevel']
        end
        required_attribs = []
        (skill/'requiredAttributes').each do |req|
          pri = doc.at(req.xpath + "/primaryAttribute")
          sec = doc.at(req.xpath + "/secondaryAttribute")
          required_attribs << Reve::Classes::PrimaryAttribute.new(pri.inner_html)
          required_attribs << Reve::Classes::SecondaryAttribute.new(sec.inner_html)
        end
        bonuses = []
        res = (skill/'rowset@name=[skillBonusCollection]/row')
        res.each do |bonus|
          next if bonus.kind_of? Hpricot::Text
          bonuses << Reve::Classes::SkillBonus.new(bonus) if bonus['bonusType'] && bonus['bonusValue']
        end
        skills << Reve::Classes::SkillTree.new(name,type_id,group_id,desc,rank,required_attribs,required_skills,bonuses)
      end
      skills
    end

    # Does big brother tracking from
    # http://api.eve-online.com/corp/MemberTracking.xml.aspx
    # Expects:
    # * characterid ( Integer | String ) - Look at players in this Character's Corporation
    # See also: Reve::Classes::MemberTracking
    def member_tracking(opts = {:characterid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@member_tracking_url))
      return h if h
      process_query(Reve::Classes::MemberTracking,opts[:url] || @@member_tracking_url,false,args)
    end
    
    
    # Gets one's research stats from agents
    # http://api.eve-online/char/Research.xml.aspx
    # Expects:
    # * characterid ( Integer | String ) - Get stats for this Character
    # See also: Reve::Classes::Research
    def research(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@research_url))
      return h if h
      process_query(Reve::Classes::Research,opts[:url] || @@research_url,false,args)      
    end

    #
    #gets contracts
    # http://api.eve-online/char/Contracts.xml.aspx
    # * characterid ( Integer | String ) - Get stats for this Character
    # See also: Reve::Classes::Contract

    def contracts(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@contracts_url))
      return h if h
      process_query(Reve::Classes::Contracts,opts[:url] || @@contracts_url,false,args)      
    end


    # Gets one's own personal WalletBalance from
    # http://api.eve-online.com/char/AccountBalance.xml.aspx
    # Expects:
    # * characterid ( Integer | String ) - Look at this player's WalletBalance
    # See also: Reve::Classes::WalletBalance and corporate_wallet_balance
    def personal_wallet_balance(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_wallet_balance_url))
      return h if h
      process_query(Reve::Classes::WalletBalance,opts[:url] || @@personal_wallet_balance_url,false,args)
    end

    # Gets one's corporate WalletBalance from 
    # http://api.eve-online.com/corp/AccountBalance.xml.aspx
    # Expects:
    # * characterid ( Integer | String ) - Look at WalletBalance objects from this Character's Corporation
    # See also:  Reve::Classes::WalletBalance and personal_wallet_balance
    def corporate_wallet_balance(opts = { :characterd => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporate_wallet_balance_url))
      return h if h
      process_query(Reve::Classes::WalletBalance,opts[:url] || @@corporate_wallet_balance_url,false,args)
    end

    # Gets one's own personal WalletTransaction list from
    # http://api.eve-online.com/char/WalletTransactions.xml.aspx
    # Expects:
    # * characterid ( Integer | String ) - Look at this player's WalletTransaction list
    # * beforetransid ( Integer | String ) - Gets a list of WalletTransaction objects from before this Transaction ID.
    # See also: Reve::Classes::WalletTransaction and
    # corporate_wallet_transactions
    def personal_wallet_transactions(opts = { :characterid => nil, :beforetransid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_wallet_trans_url) )
      return h if h
      process_query(Reve::Classes::PersonalWalletTransaction,opts[:url] || @@personal_wallet_trans_url,false,args)
    end

    # Gets one's corporate WalletTransaction list from
    # http://api.eve-online.com/corp/WalletTransactions.xml.aspx
    # Expects:
    # * account_key ( Integer | String ) - Account key (1000-1006) to look at.
    # * characterid ( Integer | String ) - Look at WalletTransaction objects from this Character's Corporation
    # * beforetransid ( Integer | String ) - Gets a list of WalletTransaction objects from before this Transaction ID.
    # See also: Reve::Classes::WalletTransaction and
    # personal_wallet_transactions
    def corporate_wallet_transactions(opts = {:accountkey => nil, :characterid => nil, :beforerefid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporate_wallet_trans_url))
      return h if h
      process_query(Reve::Classes::CorporateWalletTransaction,opts[:url] || @@corporate_wallet_trans_url,false,args)
    end

    # Gets one's own corporate WalletJournal list from
    # http://api.eve-online.com/corp/WalletJournal.xml.aspx
    # Expects:
    # * account_key ( Integer | String ) - Account key (1000-1006) to look at.
    # * characterid ( Integer | String ) - Look at WalletJournal objects from this Character's Corporation
    # * beforerefid ( Integer | String ) - Gets a list of  WalletTransaction objects from before this RefID.
    # See also: Reve::Classes::WalletJournal and personal_wallet_journal
    def corporate_wallet_journal(opts = {:accountkey => nil, :characterid => nil, :beforerefid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporate_wallet_journal_url))
      return h if h
      process_query(Reve::Classes::WalletJournal,opts[:url] || @@corporate_wallet_journal_url,false,args)
    end

    # Gets one's own personal WalletJournal list from
    # http://api.eve-online.com/char/WalletJournal.xml.aspx
    # Expects:
    # * characterid ( Integer | String ) - Look at this player's WalletJournal list
    # * beforerefid ( Integer | String ) - Gets a list of WalletJournal objects from before this RefID.
    # See also: Reve::Classes::WalletJournal and corporate_wallet_journal
    def personal_wallet_journal(opts = { :characterid => nil, :beforerefid => nil} )
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_wallet_journal_url))
      return h if h
      process_query(Reve::Classes::WalletJournal,opts[:url] || @@personal_wallet_journal_url,false,args)
    end
    
    # Get the medals a Corporation can give out. Returns a list of 
    # Reve::Classes::CorporateMedal objects.
    # Expects:
    # * characterid ( Integer | String ) - Get this Medals this Character's Corporation can give out
    # See also: Reve::Classes::CorporateMedal, Reve::Classes::Medal
    def corporate_medals(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporate_medals_url))
      return h if h
      process_query(Reve::Classes::CorporateMedal, opts[:url] || @@corporate_medals_url,false,args)
    end
    
    
    # Gets the medals the Corporation has given out. Returns a list of
    # Reve::Classes::CorporateMemberMedal
    # Expects:
    # * characterid ( Integer | String ) - Get this Medals this Character's Corporation has given out
    # See also: Reve::Classes::CorporateMedal, Reve::Classes::Medal
    def corporate_member_medals(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corp_member_medals_url))
      return h if h
      process_query(Reve::Classes::CorporateMemberMedal, opts[:url] || @@corp_member_medals_url,false,args)
    end
    
    
    # Gets the list of Medals awarded to a Character. Returns a
    # Reve::Classes::CharacterMedals object.
    def character_medals(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@character_medals_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@character_medals_url,true,args)
      current = xml.search("/eveapi/result/rowset[@name=currentCorporation]/row").inject([]) do |cur,elem|
        cur << Reve::Classes::CharacterMedal.new(elem)
      end
      other = xml.search("/eveapi/result/rowset[@name=otherCorporations]/row").inject([]) do |cur,elem|
        cur << Reve::Classes::CharacterMedal.new(elem)
      end
      Reve::Classes::CharacterMedals.new(current,other)
    end
    
    # Gets the Reve::Classes::PersonalFactionWarStat for a character.
    # Expects:
    # * characterid ( Integer | String ) - Get this character's PersonalFactionWarStat.
    # See Also Reve::Classes::PersonalFactionWarStat and corporate_faction_war_stats
    def personal_faction_war_stats(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_faction_war_stats_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@personal_faction_war_stats_url,true,args)    
      elems = {}
      [ :factionID, :factionName, :enlisted, :currentRank, :highestRank, 
        :killsYesterday, :killsLastWeek, :killsTotal, :victoryPointsYesterday,
        :victoryPointsLastWeek, :victoryPointsTotal ].each do |elem|
          elems[elem.to_s] = xml.search("/eveapi/result/" + elem.to_s).first.inner_html
        end
      Reve::Classes::PersonalFactionWarParticpant.new(elems)
    end

    # Gets the CorporateFactionWarStat for the Corporation a Character belongs to.
    # Expects:
    # * characterid ( Integer | String ) - Get this character's corp's CorporateFactionWarStat.
    # See Also Reve::Classes::CorporateFactionWarStat and personal_faction_war_stats
    def corporate_faction_war_stats(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporate_faction_war_stats_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@corporate_faction_war_stats_url,true,args)    
      elems = {}
      [ :factionID, :factionName, :enlisted, :pilots,
        :killsYesterday, :killsLastWeek, :killsTotal, :victoryPointsYesterday,
        :victoryPointsLastWeek, :victoryPointsTotal ].each do |elem|
          elems[elem.to_s] = xml.search("/eveapi/result/" + elem.to_s).first.inner_html
        end
      Reve::Classes::CorporateFactionWarParticpant.new(elems)
    end
    
    # Gets Faction-wide war stats.
    # See also: Reve::Classes::EveFactionWarStat, Reve::Classes::FactionwideFactionWarParticpant, 
    # Reve::Classes::FactionWar
    def faction_war_stats(opts = {} )
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@general_faction_war_stats_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@general_faction_war_stats_url,true,args)
      participants = xml.search("/eveapi/result/rowset[@name='factions']/row").collect do |faction|
        Reve::Classes::FactionwideFactionWarParticpant.new(faction)
      end
      wars = xml.search("/eveapi/result/rowset[@name='factionWars']/row").collect do |faction_war|
        Reve::Classes::FactionWar.new(faction_war)
      end
      totals = {}
      [ :killsYesterday, :killsLastWeek, :killsTotal, :victoryPointsYesterday,
        :victoryPointsLastWeek, :victoryPointsTotal ].each do |elem|
        totals[elem.to_s] = xml.search("/eveapi/result/totals/" + elem.to_s).first.inner_html
      end
      Reve::Classes::EveFactionWarStat.new(totals, wars, participants)
    end
    
    # Returns the occupancy data for each System.
    # See also: Reve::Classes::FactionWarSystemStatus
    def faction_war_system_stats(opts = {})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@faction_war_occupancy_url))
      return h if h
      process_query(Reve::Classes::FactionWarSystemStatus,opts[:url] || @@faction_war_occupancy_url,false,args)
    end
    alias_method :faction_war_occupancy, :faction_war_system_stats
    
    # Gets a list of the top 10 statistics for Characters, Corporations and 
    # Factions in factional warfare. Read the notes on Reve::Classes::FactionWarTopStats.
    def faction_war_top_stats(opts = {})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@top_faction_war_stats_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@top_faction_war_stats_url,true,args)
      template = { :yesterday_kills => "KillsYesterday", :last_week_kills => "KillsLastWeek", :total_kills => "KillsTotal",
                   :yesterday_victory_points => 'VictoryPointsYesterday', :last_week_victory_points => 'VictoryPointsLastWeek', :total_victory_points => 'VictoryPointsTotal' }
      # Inject here to save 60 lines.
      characters = template.inject({}) do |h,(key,val)|
        klass = key.to_s =~ /kills/ ? Reve::Classes::CharacterFactionKills : Reve::Classes::CharacterFactionVictoryPoints
        h[key] = pull_out_top_10_data(xml,klass,'characters',val)
        h
      end
      corporations = template.inject({}) do |h,(key,val)|
        klass = key.to_s =~ /kills/ ? Reve::Classes::CorporationFactionKills : Reve::Classes::CorporationFactionVictoryPoints
        h[key] = pull_out_top_10_data(xml,klass,'corporations',val)
        h
      end
      factions = template.inject({}) do |h,(key,val)|
        klass = key.to_s =~ /kills/ ? Reve::Classes::FactionKills : Reve::Classes::FactionVictoryPoints
        h[key] = pull_out_top_10_data(xml,klass,'factions',val)
        h
      end
      Reve::Classes::FactionWarTopStats.new(characters,corporations,factions)
    end

    # Get a list of personal assets for the characterid.
    # See the Reve::Classes::Asset and Reve::Classes::AssetContainer classes
    # for attributes available.
    def personal_assets_list(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_assets_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@personal_assets_url,true,args)
      self.recur_through_assets(xml.search("/eveapi/result/rowset[@name='assets']/row"))
    end
    
    # Get a list of the Corporate Assets. Pass the characterid of the Corporate member See also assets_list method
    def corporate_assets_list(opts = { :characterid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporate_assets_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@corporate_assets_url,true,args)
      self.recur_through_assets(xml.search("/eveapi/result/rowset[@name='assets']/row"))
    end

    # Returns a Character list for the associated key from
    # http://api.eve-online.com/account/Characters.xml.aspx
    # See also: Reve::Classes::Character
    def characters(opts = {})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@characters_url))
      return h if h
      process_query(Reve::Classes::Character,opts[:url] || @@characters_url,false,args)
    end

    # Gets the SkillInTraining from
    # http://api.eve-online.com/char/SkillInTraining.xml.aspx
    # Expects:
    # * characterid ( Integer | String ) - Get the SkillInTraining for this Character
    # See also: Reve::Classes::SkillInTraining
    def skill_in_training(opts = {:characterid => nil})
      args = postfields(opts)
      ch = compute_hash(args.merge(:url => @@training_skill_url))
      return ch if ch
      h = {}
      xml = process_query(nil,opts[:url] || @@training_skill_url,true,args)
      xml.search("//result").each do |elem|
        for field in [ 'currentTQTime', 'trainingEndTime','trainingStartTime','trainingTypeID','trainingStartSP','trainingDestinationSP','trainingToLevel','skillInTraining' ]
          h[field] = (elem/field.intern).inner_html
        end
      end
      Reve::Classes::SkillInTraining.new(h)
    end
    
    # Returns a list of Reve::Classes::QueuedSkill for characterid
    # http://api.eve-online.com/char/SkillQueue.xml.aspx
    # Expects:
    # * characterid ( Integer | String ) - Get the QueuedSkill list for this character
    # See also Reve::Classes::QueuedSkill
    def skill_queue(opts = {:characterid => nil})
      args = postfields(opts)
      ch = compute_hash(args.merge(:url => @@skill_queue_url))
      return ch if ch
      process_query(Reve::Classes::QueuedSkill,opts[:url] || @@skill_queue_url,false,args)
    end
    
    # Returns a list of Reve::Classes::Starbase for characterid's Corporation.
    # http://api.eve-online.com/corp/StarbaseList.xml.aspx
    # Expects:
    # * characterid ( Integer | String ) - Get the Starbase list for this character's Corporation
    # See also Reve::Classes::Starbase
    def starbases(opts = { :characterid => nil})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@starbases_url))
      return h if h
      process_query(Reve::Classes::Starbase,opts[:url] || @@starbases_url,false,args)
    end
    
    # Returns the starbase details for the Starbase whose item id is starbase_id
    # http://api.eve-online.com/corp/StarbaseDetail.xml.aspx
    # Expects:
    # * characterid ( Integer | String ) - Get the Starbase associated wih this character's Corporation
    # * starbaseid ( Integer ) - Get the fuel for this Starbase. This is the Starbase's itemid.
    # See also Reve::Classes::StarbaseDetails
    def starbase_details(opts = { :characterid => nil, :starbaseid => nil })
      opts[:itemid] = opts.delete(:starbaseid)
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@starbasedetail_url))
      return h if h
      xml = process_query(Reve::Classes::StarbaseDetails,opts[:url] || @@starbasedetail_url, true, args)
      
      state = xml.search("/eveapi/result/state").inner_text
      state_timestamp = xml.search("/eveapi/result/stateTimestamp").inner_text
      online_timestamp = xml.search("/eveapi/result/onlineTimestamp").inner_text
      
      h = {'usageFlags' => 0, 'deployFlags' => 0, 'allowCorporationMembers' => 0, 'allowAllianceMembers' => 0, 'claimSovereignty' => 0}
      h.keys.each {|k| h[k] = xml.search("/eveapi/result/generalSettings/#{k}").inner_text }
      general_settings = Reve::Classes::StarbaseGeneralSettings.new(h)
      
      h = {'onStandingDrop' => 0, 'onStatusDrop' => 0, 'onAggression' => 0, 'onCorporationWar' => 0}
      h.keys.each {|k| h[k] = xml.search("/eveapi/result/combatSettings/#{k}") }
      combat_settings = Reve::Classes::StarbaseCombatSettings.new(h)
      
      fuel = []
      xml.search("/eveapi/result/rowset[@name='fuel']/row").each do |entry|
        fuel << Reve::Classes::StarbaseFuel.new(entry)
      end
      
      res = Hash.new
      { :state => :state, :stateTimestamp => :state_timestamp, :onlineTimestamp => :online_timestamp }.each do |k,v|
        res[v] = xml.search("/eveapi/result/#{k.to_s}/").first.to_s.strip
      end
      
      Reve::Classes::StarbaseDetails.new res, general_settings, combat_settings, fuel
    end
    
    alias_method  :starbase_fuel, :starbase_details
    
    
    # Get the last kills for the characterid passed.
    # Expects:
    # * Hash of arguments
    # * * characterid ( Integer ) - The Character whose Kills to retrieve
    # * * beforekillid ( Integer ) - (Optional) - Return the most recent kills before this killid.
    def personal_kills(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_kills_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@personal_kills_url,true,args)
      kills = []
      xml.search("/eveapi/result/rowset/row").each do |e|
        victim = Reve::Classes::KillVictim.new(e.search("victim").first) rescue next # cant find victim
        attackers = []
        losses = []
        e.search("rowset[@name='attackers']/row").each do |attacker|
          attackers << Reve::Classes::KillAttacker.new(attacker)
        end
        e.search("rowset[@name='items']/row").each do |lost_item|
          lost = Reve::Classes::KillLoss.new(lost_item)
          lost_item.search("rowset[@name='items']/row").each do |contained|
            lost.contained_losses << Reve::Classes::KillLoss.new(contained)
          end
          losses << lost
        end
        kills << Reve::Classes::Kill.new(e, victim, attackers, losses)      
      end
      kills
    end
    
    # See the options for personal_kills
    def corporate_kills(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporate_kills_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@corporate_kills_url,true,args)
      kills = []
      xml.search("/eveapi/result/rowset/row").each do |e|
        victim = Reve::Classes::KillVictim.new(e.search("victim").first) rescue next # cant find victim
        attackers = []
        losses = []
        e.search("rowset[@name='attackers']/row").each do |attacker|
          attackers << Reve::Classes::KillAttacker.new(attacker)
        end
        e.search("rowset[@name='items']/row").each do |lost_item|
          lost = Reve::Classes::KillLoss.new(lost_item)
          lost_item.search("rowset[@name='items']/row").each do |contained|
            lost.contained_losses << Reve::Classes::KillLoss.new(contained)
          end
          losses << lost
        end
        kills << Reve::Classes::Kill.new(e, victim, attackers, losses)      
      end
      kills
    end
    
    # Gets the CorporationSheet from http://api.eve-online.com/corp/CorporationSheet.xml.aspx
    # Expects:
    # * Hash of arguments:
    # * * characterid ( Integer | String ) - Gets the CorporationSheet for this Character
    # * * corporationid ( Integer ) - If the characterid isn't passed then send the corporation's id 
    # (See the alliances method for a list) to get the details of a Corporation that belongs to an Alliance.
    # See also: Reve::Classes::CorporationSheet
    def corporation_sheet(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporation_sheet_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@corporation_sheet_url,true,args)

      h = { 'graphicid' => 0, 'shape1' => 0, 'shape2' => 0, 'shape3' => 0, 'color1' => 0, 'color2' => 0, 'color3' => 0,  }
      h.keys.each { |k| h[k] = xml.search("//result/logo/" + k + "/").to_s.to_i }
      corporate_logo = Reve::Classes::CorporateLogo.new h
      
      wallet_divisions = xml.search("//result/rowset[@name='walletDivisions']/").collect { |k| k if k.kind_of? Hpricot::Elem } - [ nil ]
      divisions = xml.search("//result/rowset[@name='divisions']/").collect { |k| k if k.kind_of? Hpricot::Elem } - [ nil ]
      divisions.collect! { |d| Reve::Classes::CorporateDivision.new(d) }
      wallet_divisions.collect! { |w| Reve::Classes::WalletDivision.new(w) }
      
      # Map the XML names to our own names and assign them to the temporary 
      # hash +res+ to pass to Reve::Classes::CorporationSheet#new
      res = Hash.new
      { :corporationid => :id, :corporationname => :name, :ticker => :ticker, :ceoid => :ceo_id,
        :ceoname => :ceo_name, :stationid => :station_id, :stationname => :station_name,
        :description => :description, :url => :url, :allianceid => :alliance_id,
        :alliancename => :alliance_name, :taxrate => :tax_rate, :membercount => :member_count,
        :memberlimit => :member_limit, :shares => :shares }.each do |k,v|
        res[v] = xml.search("//result/#{k.to_s}/").first.to_s.strip
      end

      Reve::Classes::CorporationSheet.new res, divisions, wallet_divisions, corporate_logo  
    end
    
    def corporate_member_security(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@corporation_member_security_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@corporation_member_security_url,true,args)

      cmc = Reve::Classes::CorporationMemberSecurity.new
      xml.search("/eveapi/result/rowset[@name=members]/row").each do |member|
        mem = Reve::Classes::CorporationMember.new(member)
        cmc.members << mem
        [:roles, :grantableRoles, :rolesAtHQ, :grantableRolesAtHQ, :rolesAtBase, :grantableRolesAtBase, :rolesAtOther, :grantableRolesAtOther].each do |rowset|
          member.search("/rowset[@name=#{rowset.to_s}]/row").each do |row|
            mem.rsend(["#{rowset}"], [:push,Reve::Classes::CorporateRole.new(row)])
          end
        end
        member.search("/rowset[@name=titles]/row").each do |row|
          mem.rsend([:titles], [:push,Reve::Classes::CorporateTitle.new(row)])
        end
      end
      cmc
    end
    
    # Returns a Reve::Classes::CertificateTree object that contains the
    # Certificate tree structure. See the rdoc for Reve::Classes::CertificateTree
    # for details.
    # See also: Reve::Classes::CertificateTree
    def certificate_tree(opts = {})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@certificate_tree_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@certificate_tree_url,true,args)
      
      tree = Reve::Classes::CertificateTree.new
      xml.search("/eveapi/result/rowset[@name=categories]/row").each do |category|
        cat = Reve::Classes::CertificateCategory.new(category)
        category.search("rowset[@name=classes]/row").each do |klass|
          kl = Reve::Classes::CertificateClass.new(klass)
          klass.search("rowset[@name=certificates]/row").each do |certificate|
            cert = Reve::Classes::Certificate.new(certificate)
            certificate.search("rowset[@name=requiredSkills]/row").each do |skill|
              cert.required_skills << Reve::Classes::CertificateRequiredSkill.new(skill)
            end
            certificate.search("rowset[@name=requiredCertificates]/row").each do |requiredcert|
              cert.required_certificates << Reve::Classes::CertificateRequiredCertificate.new(requiredcert)
            end
            kl.certificates << cert
          end
          cat.classes << kl
        end
        tree.categories << cat
      end
      tree
    end

    # Gets the CharacterSheet from
    # http://api.eve-online.com/char/CharacterSheet.xml.aspx
    # Expects:
    # * characterid ( Fixnum ) - Get the CharacterSheet for this Character
    # See also: Reve::Classes::CharacterSheet
    def character_sheet(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@character_sheet_url))
      return h if h
      
      xml = process_query(nil,opts[:url] || @@character_sheet_url,true,args)
      cs = Reve::Classes::CharacterSheet.new

      [ Reve::Classes::IntelligenceEnhancer, Reve::Classes::MemoryEnhancer, Reve::Classes::CharismaEnhancer,
        Reve::Classes::PerceptionEnhancer, Reve::Classes::WillpowerEnhancer
      ].each do |klass|
        xml_attr = klass.to_s.split("::").last.sub("Enhancer",'').downcase + "Bonus"
        i = klass.new(xml.search("/eveapi/result/attributeEnhancers/#{xml_attr}").search("augmentatorName/").first.to_s,
                      xml.search("/eveapi/result/attributeEnhancers/#{xml_attr}").search("augmentatorValue/").first.to_s.to_i)
        cs.enhancers << i
      end

      [ 'characterID', 'name', 'race', 'bloodLine', 'ancestry', 'dob', 'gender','corporationName',
        'corporationID','balance', 'cloneName', 'cloneSkillPoints' 
      ].each do |field|
        cs.send("#{field.downcase}=",xml.search("/eveapi/result/#{field}/").first.to_s)
      end
      
      [ 'intelligence','memory','charisma','perception','willpower' ].each do |attrib|
        cs.send("#{attrib}=",xml.search("/eveapi/result/attributes/#{attrib}/").first.to_s.to_i) 
      end
      xml.search("rowset[@name=skills]/row").each do |elem|
        cs.skills << Reve::Classes::Skill.new(elem)
      end
      
      xml.search("rowset[@name=certificates]/row").each do |elem|
        cs.certificate_ids << elem['certificateID'].to_i
      end
      [ :corporationRolesAtHQ, :corporationRoles, :corporationRolesAtBase, :corporationRolesAtOther ].each do |role_kind|
        xml.search("rowset[@name=#{role_kind.to_s}]/row").each do |elem|
          cs.rsend(["#{role_kind}"], [:push,Reve::Classes::CorporateRole.new(elem)])
        end
      end
      
      xml.search("rowset[@name=corporationTitles]/row").each do |elem|
        cs.corporate_titles << Reve::Classes::CorporateTitle.new(elem)
      end
      
      cs
    end
    
    # Gets the characters notifications. Returns a list of
    # Reve::Classes::Notification
    # Expects:
    # * characterid ( Integer | String ) - Get the Notifications for this Character
    # See also: Reve::Classes::Notification
    def personal_notifications(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_notification_url))
      return h if h
      process_query(Reve::Classes::Notification, opts[:url] || @@personal_notification_url,false,args)
    end
    
    # Gets the characters notifications. Returns a list of
    # Reve::Classes::MailingList
    # Expects:
    # * characterid ( Integer | String ) - Get the MailingLists for this Character
    # See also: Reve::Classes::MailingList
    def personal_mailing_lists(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_mailing_lists_url))
      return h if h
      process_query(Reve::Classes::MailingList, opts[:url] || @@personal_mailing_lists_url,false,args)
    end
    
    # Gets the characters notifications. Returns a list of
    # Reve::Classes::MailMessage
    # Expects:
    # * characterid ( Integer | String ) - Get the MailMessages for this Character
    # See also: Reve::Classes::MailMessage
    def personal_mail_messages(opts = { :characterid => nil })
      with_bodies = opts.include?(:with_bodies) ? opts.delete(:with_bodies) : false
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_mail_messages_url))
      return h if h
      messages = process_query(Reve::Classes::MailMessage, opts[:url] || @@personal_mail_messages_url,false,args)
      if with_bodies
        ids = messages.collect{|m| m.id }
        bodies = personal_mail_message_bodies(:ids => ids)
        messages.each do |msg|
          # For now we are ignoring messages that come back saying
          # body is missing. So use fetch to assign body to message
          msg.body = bodies.fetch(msg.id.to_s, nil)
        end
      end
      messages
    end

    # Gets the bodies for mail messages. NB this API call does not
    # return objects.  It returns a hash with messageID strings as the keys -
    # suitable for merging into a Reve::Classes::MailMessage object
    # 
    # Note from the Eve API docs: 
    #   Bodies cannot be accessed if you have not called for their headers recently.
    # 
    # Expects:
    # * ids ( List of Integers ) - List of message ids for which we want bodies
    # See also: Reve::Classes::MailMessage
    def personal_mail_message_bodies(opts = { :ids => [] })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@personal_mail_message_bodies_url))
      return h if h
      just_xml = true
      xml = process_query(Reve::Classes::MailMessage, opts[:url] || @@personal_mail_message_bodies_url,just_xml,args)
      results = {}
      xml.search("//rowset/row").each do |el| 
        results[el.attributes['messageID']] = el.inner_text
      end
      results
    end




    #Gets upcoming calendar events
    #Reve::Classes::UpcomingCalendarEvents
    def upcoming_calendar_events(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@upcoming_calendar_events_url))
      return h if h
      process_query(Reve::Classes::UpcomingCalendarEvents, opts[:url] || @@upcoming_calendar_events_url,false,args)
    end






    # Gets the status of the selected account. Returns
    # Reve::Classes::AccountStatus
    def account_status(opts = {})
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@account_status_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@account_status_url,true,args)
      Reve::Classes::AccountStatus.new(xml.search('//result').first)
    end
    
    # Gets the character info sheet for the selected Character
    # Reve::Classes::CharacterInfo
    def character_info(opts = { :characterid => nil })
      args = postfields(opts)
      h = compute_hash(args.merge(:url => @@character_info_url))
      return h if h
      xml = process_query(nil,opts[:url] || @@character_info_url,true,args)
      Reve::Classes::CharacterInfo.new(xml.search('//result').first)
    end

    #protected
    include REVE::ProcessingHelpers
  end
end
