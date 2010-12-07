module Reve
  module Methods
    module Eve
      
      include Reve::Urls
      
      # Gets the character info sheet for the selected Character
      # Reve::Classes::CharacterInfo
      def character_info(opts = { :characterid => nil })
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@character_info_url))
        return h if h
        xml = process_query(nil,opts[:url] || @@character_info_url,true,args)
        Reve::Classes::CharacterInfo.new(xml.search('//result').first)
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
      def character_name(opts = {})
        ids = opts[:ids] || []
        return [] if ids.empty?
        opts[:ids] = ids.join(',')
        compute_hash(  opts.merge(:url => @@character_name_url) ) ||
          process_query(Reve::Classes::Character,opts[:url] || @@character_name_url,false,opts)
      end
      
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
      
      # Returns a list of API Errors
      def errors(opts = {})
        compute_hash(  opts.merge(:url => @@errors_url) ) || 
          process_query(Reve::Classes::APIError,opts[:url] || @@errors_url,false)
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
      
    end # Reve::Methods::Eve
  end
end
