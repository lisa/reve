module Reve
  module Methods
    module Corp

      include Reve::Methods::Urls

      # Returns a list of Reve::Classes::MarketOrder objects for market orders that are up on behalf of a Corporation
      # Pass the characterid of the Character of whose corporation to check for
      def corporate_market_orders(opts = {:characterid => nil})
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@corporate_market_orders_url))
        return h if h
        process_query(Reve::Classes::CorporateMarketOrder, opts[:url] || @@corporate_market_orders_url, false, args)
      end


      # Returns a list of Reve::Classes::CorporateIndustryJob objects.
      def corporate_industry_jobs(opts = {:characterid => nil})
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@corporate_industry_jobs_url))
        return h if h
        process_query(Reve::Classes::CorporateIndustryJob, opts[:url] || @@corporate_industry_jobs_url,false,args)
      end


      # Returns a list of Reve::Classes::CorporateContact objects.
      def corporate_contacts(opts = {:characterid => nil})
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@corporate_contacts_url))
        return h if h
        process_query(Reve::Classes::PersonalContact, opts[:url] || @@corporate_contacts_url,false,args)
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
        xml.search("/eveapi/result/member").each do |member|
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

      # Get a list of the Corporate Assets. Pass the characterid of the Corporate member See also assets_list method
      def corporate_assets_list(opts = { :characterid => nil})
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@corporate_assets_url))
        return h if h
        xml = process_query(nil,opts[:url] || @@corporate_assets_url,true,args)
        assets = []
        xml.search("/eveapi/result/rowset/row").each do |container|
          asset_container = Reve::Classes::AssetContainer.new(container)
          container.search("rowset[@name='contents']/row").each do |asset|
            asset_container.assets << Reve::Classes::Asset.new(asset)
          end
          assets << asset_container
        end
        assets
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
    end # Reve::Methods::Corp
  end
end
