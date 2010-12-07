module Reve
  module Methods
    module Account

      include Reve::Urls
      
      # Gets the status of the selected account. Returns
      # Reve::Classes::AccountStatus
      def account_status(opts = {})
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@account_status_url))
        return h if h
        xml = process_query(nil,opts[:url] || @@account_status_url,true,args)
        Reve::Classes::AccountStatus.new(xml.search('//result').first)
      end
      
      
      # Returns a Character list for the associated key and userid from
      # http://api.eve-online.com/account/Characters.xml.aspx
      # See also: Reve::Classes::Character
      def characters(opts = {})
        args = postfields(opts)
        h = compute_hash(args.merge(:url => @@characters_url))
        return h if h
        process_query(Reve::Classes::Character,opts[:url] || @@characters_url,false,args)
      end
      
      
    end # Reve::Methods::Account
  end
end
