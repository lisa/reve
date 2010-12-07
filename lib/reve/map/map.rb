module Reve
  module Methods
    module Map
      include Reve::Methods::Urls

      
      # Returns the occupancy data for each System.
      # See also: Reve::Classes::FactionWarSystemStatus
      def faction_war_system_stats(opts = {})
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@faction_war_occupancy_url))
        return h if h
        process_query(Reve::Classes::FactionWarSystemStatus,opts[:url] || @@faction_war_occupancy_url,false,args)
      end
      alias_method :faction_war_occupancy, :faction_war_system_stats
      
      # Returns the Sovereignty list from
      # http://api.eve-online.com/map/Sovereignty.xml.aspx
      # See also: Reve::Classes::Sovereignty
      def sovereignty(opts = {})
        compute_hash(  opts.merge(:url => @@sovereignty_url) ) || 
          process_query(Reve::Classes::Sovereignty,opts[:url] || @@sovereignty_url,false)
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
      
      
    end # Reve::Methods::Map
  end
end
