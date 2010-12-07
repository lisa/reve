module Reve
  module Methods
    module Server
      include Reve::Urls
      
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
    end # Reve::Methods::Server
  end
end
