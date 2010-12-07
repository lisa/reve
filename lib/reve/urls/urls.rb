require File.join(File.dirname(__FILE__),'../','extensions.rb')


module Reve
  module Urls
    
    @@characters_url                  = 'http://api.eve-online.com/account/Characters.xml.aspx'    #
    @@account_status_url              = 'http://api.eve-online.com/account/AccountStatus.xml.aspx' #
          
    @@character_info_url              = 'http://api.eve-online.com/eve/CharacterInfo.xml.aspx' #
    @@alliances_url                   = 'http://api.eve-online.com/eve/AllianceList.xml.aspx' #
    @@reftypes_url                    = 'http://api.eve-online.com/eve/RefTypes.xml.aspx' #
    @@skill_tree_url                  = 'http://api.eve-online.com/eve/SkillTree.xml.aspx'
    @@conqurable_outposts_url         = 'http://api.eve-online.com/eve/ConquerableStationList.xml.aspx' #
    @@errors_url                      = 'http://api.eve-online.com/eve/ErrorList.xml.aspx' #
    @@character_id_url                = 'http://api.eve-online.com/eve/CharacterID.xml.aspx'   # ?names=CCP%20Garthagk
    @@character_name_url              = 'http://api.eve-online.com/eve/CharacterName.xml.aspx' # ?ids=797400947
    @@general_faction_war_stats_url   = 'http://api.eve-online.com/eve/FacWarStats.xml.aspx' #
    @@top_faction_war_stats_url       = 'http://api.eve-online.com/eve/FacWarTopStats.xml.aspx' #
    @@certificate_tree_url            = 'http://api.eve-online.com/eve/CertificateTree.xml.aspx' #
    
    @@character_medals_url            = 'http://api.eve-online.com/char/Medals.xml.aspx'  #
    @@personal_wallet_trans_url       = 'http://api.eve-online.com/char/WalletTransactions.xml.aspx' #
    @@personal_wallet_journal_url     = 'http://api.eve-online.com/char/WalletJournal.xml.aspx'      #
    @@personal_wallet_balance_url     = 'http://api.eve-online.com/char/AccountBalance.xml.aspx'     #
    @@training_skill_url              = 'http://api.eve-online.com/char/SkillInTraining.xml.aspx'    #
    @@skill_queue_url                 = 'http://api.eve-online.com/char/SkillQueue.xml.aspx'         #
    @@character_sheet_url             = 'http://api.eve-online.com/char/CharacterSheet.xml.aspx'     #
    @@personal_market_orders_url      = 'http://api.eve-online.com/char/MarketOrders.xml.aspx' #
    @@personal_industry_jobs_url      = 'http://api.eve-online.com/char/IndustryJobs.xml.aspx' #
    @@personal_kills_url              = 'http://api.eve-online.com/char/KillLog.xml.aspx' #
    @@personal_faction_war_stats_url  = 'http://api.eve-online.com/char/FacWarStats.xml.aspx' #
    @@personal_assets_url             = 'http://api.eve-online.com/char/AssetList.xml.aspx' #
    @@research_url                    = 'http://api.eve-online.com/char/Research.xml.aspx' #
    @@personal_notification_url       = 'http://api.eve-online.com/char/Notifications.xml.aspx' #
    @@personal_mailing_lists_url      = 'http://api.eve-online.com/char/mailinglists.xml.aspx'  #
    @@personal_mail_messages_url      = 'http://api.eve-online.com/char/MailMessages.xml.aspx' #
    @@personal_contacts_url           = 'http://api.eve-online.com/char/ContactList.xml.aspx'
    
    @@member_tracking_url             = 'http://api.eve-online.com/corp/MemberTracking.xml.aspx'
    @@corporate_wallet_balance_url    = 'http://api.eve-online.com/corp/AccountBalance.xml.aspx'      
    @@corporate_wallet_trans_url      = 'http://api.eve-online.com/corp/WalletTransactions.xml.aspx'
    @@corporate_wallet_journal_url    = 'http://api.eve-online.com/corp/WalletJournal.xml.aspx'
    @@starbases_url                   = 'http://api.eve-online.com/corp/StarbaseList.xml.aspx'
    @@starbasedetail_url              = 'http://api.eve-online.com/corp/StarbaseDetail.xml.aspx'
    @@corporation_sheet_url           = 'http://api.eve-online.com/corp/CorporationSheet.xml.aspx'
    @@corporation_member_security_url = 'http://api.eve-online.com/corp/MemberSecurity.xml.aspx'
    @@corporate_market_orders_url     = 'http://api.eve-online.com/corp/MarketOrders.xml.aspx'
    @@corporate_industry_jobs_url     = 'http://api.eve-online.com/corp/IndustryJobs.xml.aspx'
    @@corporate_assets_url            = 'http://api.eve-online.com/corp/AssetList.xml.aspx'
    @@corporate_kills_url             = 'http://api.eve-online.com/corp/KillLog.xml.aspx'
    @@corporate_faction_war_stats_url = 'http://api.eve-online.com/corp/FacWarStats.xml.aspx'
    @@corporate_medals_url            = 'http://api.eve-online.com/corp/Medals.xml.aspx'
    @@corp_member_medals_url          = 'http://api.eve-online.com/corp/MemberMedals.xml.aspx'
    @@corporate_contacts_url          = 'http://api.eve-online.com/corp/ContactList.xml.aspx'
    
    @@sovereignty_url                 = 'http://api.eve-online.com/map/Sovereignty.xml.aspx' #
    @@map_jumps_url                   = 'http://api.eve-online.com/map/Jumps.xml.aspx' #
    @@map_kills_url                   = 'http://api.eve-online.com/map/Kills.xml.aspx' #
    @@faction_war_occupancy_url       = 'http://api.eve-online.com/map/FacWarSystems.xml.aspx' #
    
    
    @@server_status_url               = 'http://api.eve-online.com/Server/ServerStatus.xml.aspx' #

    

    Class.cattr_accessor :character_sheet_url, :training_skill_url, :characters_url, :personal_wallet_journal_url,
                   :corporate_wallet_journal_url, :corporate_wallet_trans_url, :personal_wallet_trans_url, 
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
                   :research_url, :personal_contacts_url, :corporate_contacts_url,
                   :account_status_url, :character_info_url
  end
end
