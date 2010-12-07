module Reve
  module Methods
    module Char

      
      ############ Character-related methods follow
      
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

        [ 'characterID', 'name', 'race', 'bloodLine', 'gender','corporationName',
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
      
      # Get a list of personal assets for the characterid.
      # See the Reve::Classes::Asset and Reve::Classes::AssetContainer classes
      # for attributes available.
      def personal_assets_list(opts = { :characterid => nil })
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@personal_assets_url))
        return h if h
        xml = process_query(nil,opts[:url] || @@personal_assets_url,true,args)
        assets = []
        xml.search("/eveapi/result/rowset[@name='assets']/row").each do |container|
          asset_container = Reve::Classes::AssetContainer.new(container)
          container.search("rowset[@name='contents']/row").each do |asset|
            asset_container.assets << Reve::Classes::Asset.new(asset)
          end
          assets << asset_container
        end
        assets
      end
      
      # Returns a list of Reve::Classes::PersonalContact objects.
      def personal_contacts(opts = {:characterid => nil})
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@personal_contacts_url))
        return h if h
        process_query(Reve::Classes::PersonalContact, opts[:url] || @@personal_contacts_url,false,args)
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
      
      
      # Returns a list of Reve::Classes::PersonalIndustryJob objects.
      def personal_industry_jobs(opts = {:characterid => nil})
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@personal_industry_jobs_url))
        return h if h
        process_query(Reve::Classes::PersonalIndustryJob, opts[:url] || @@personal_industry_jobs_url,false,args)
      end
      
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
      
      # Returns a list of Reve::Classes::MarketOrder objects for market orders that are up
      # Pass the characterid of the Character to check for
      def personal_market_orders(opts = {:characterid => nil})
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@personal_market_orders_url))
        return h if h
        process_query(Reve::Classes::PersonalMarketOrder, opts[:url] || @@personal_market_orders_url, false, args)
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
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@personal_mail_messages_url))
        return h if h
        process_query(Reve::Classes::MailMessage, opts[:url] || @@personal_mail_messages_url,false,args)
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
      
      
    end # End Reve::Methods::Char
  end # End Reve::Methods
end