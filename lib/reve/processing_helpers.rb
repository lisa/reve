module REVE
  module ProcessingHelpers

# Helper method to handle nested assets
    def recur_through_assets(rows)
      assets = []
      rows.each do |container|
        unless container.empty?  
          asset_container = Reve::Classes::AssetContainer.new(container)
          asset_container.assets = self.recur_through_assets(container.search("/rowset/row"))
          assets << asset_container 
        else
          assets << Reve::Classes::Asset.new(container)
        end
      end 
      assets
    end
    
    # Sets up the post fields for Net::HTTP::Get hash for process_query method.
    # See also format_url_request
    # TODO: Consider moving this whole thing into process_query to avoid 
    # calling this in every method!
    def postfields(opts = {})
      baseargs = { :characterid => @charid }
      if @cak
        baseargs[:keyid] = @keyid
        baseargs[:vcode] = @key
      else
        baseargs[:userid] = @keyid
        baseargs[:apikey] = @key
      end
      ret = opts.clone
      baseargs.each do |k,v|
        if ret[k].nil?
          ret[k] = v
        end
      end
      ret.inject({}) do |n, (k,v)|
        n[k.downcase] = v.to_s if v
        n
      end
    end
    
    # Creates a hash for some hash of postfields. For each API method pass 
    # :just_hash => to something to return a hash that can be matched to 
    # the last_hash instance method created in process_query.
    # This method is called in each API method before process_query and if 
    # :just_hash was passed in args then a String will be returned, otherwise
    # nil will be returned
    # TODO: Consider moving this whole thing into process_query before the URI parsing
    def compute_hash(args = {})
      args.stringify_keys!
      return nil unless args.include?('just_hash')
      args.delete('just_hash')
      url = args['url'].kind_of?(URI) ? args['url'].path : args['url']
      args.delete('url')
      spl = url.split '/'
      ret = (spl[-2] + '/' + spl[-1]) + ':'
      args.delete_if { |k,v| (v || "").to_s.length == 0 } # Delete keys if the value is nil
      h = args.stringify_keys
      ret += h.sort.flatten.collect{ |e| e.to_s }.join(':')
      ret.gsub(/:$/,'')
    end

    # Processes a URL and for simple <rowset><row /><row /></rowset> results
    # create an array of objects of type klass. Or just return the XML if
    # just_xml is set true. args is from postfields
    # This method will call check_exception to see if an Exception came from
    # CCP.
    # Expects:
    # * klass ( Class ) - The class container for parsing. An array of these is returned in default behaviour.
    # * url ( String ) - API URL
    # * just_xml ( Boolean ) - Return only the XML and not attempt to parse //rowset/row. Useful if the XML is not in that form.
    # * args ( Hash ) - Hash of arguments for the request. See postfields method.
    def process_query(klass, url, just_xml = false, opts = {})

      #args = postfields(opts)
      #h = compute_hash(args.merge(:url => url))
      #return h if h

      @last_hash = compute_hash(opts.merge({:url => url, :just_hash => true })) # compute hash


      xml = check_exception(get_xml(url,opts))
      save_xml(xml) if @save_path

      return xml if just_xml
      return [] if xml.nil? # No XML document returned. We should panic.
      
      # Create the array of klass objects to return, assume we start with an empty set from the XML search for rows
      # and build from there.
      xml.search("//rowset/row").inject([]) { |ret,elem| ret << klass.new(elem) }
    end
    
    # Turns a hash into ?var=baz&bam=boo
    def format_url_request(opts)
      req = "?"

      opts.stringify_keys!
      opts.keys.sort.each do |key|
        req += "#{CGI.escape(key.to_s)}=#{CGI.escape(opts[key].to_s)}&" if opts[key]
      end
      req.chop # We are lazy and append a & to each pair even if it's the last one. FIXME: Don't do this.
    end
    
    
    # Gets the XML from a source.
    # Expects:
    # * source ( String | URI ) - If the +source+ is a String Reve will attempt to load the XML file from the local filesystem by the path specified as +source+. If the +source+ is a URI or is a String starting with http (lowercase) Reve will fetch it from that URI on the web.
    # * opts ( Hash ) - Hash of parameters for the request, such as keyid, vcode and such.
    # NOTE: To override the lowercase http -> URI rule make the HTTP part uppercase.
    def get_xml(source,opts)
      xml = ""
      
      # Let people still pass Strings starting with http.
      if source =~ /^http/
        source = URI.parse(source)
      end
      
      if source.kind_of?(URI)
        opts.merge({ :version => 2, :url => nil }) #the uri bit will now ignored in format_url_request
        req_args =  format_url_request(opts)
        req = Net::HTTP::Get.new(source.path + req_args)
        req['User-Agent'] = @http_referer_agent || "Reve v#{@reve_version}; http://github.com/lisa/reve"
        
        res = nil
        response = nil
        1.upto(@max_tries) do |try|
          begin
            # ||= to prevent making a new Net::HTTP object, the res = nil above should reset this for the next request.
            # the request needs to be here to rescue exceptions from it.
            http ||= Net::HTTP.new(source.host, source.port)
            http.use_ssl = true
            http.verify_mode = OpenSSL::SSL::VERIFY_NONE  ##rework to use proper cert
            http.open_timeout = 3
            http.read_timeout = @timeout
            res = http.start {|http| http.request(req) }
            case res
            when Net::HTTPSuccess, Net::HTTPRedirection
              response = res.body
            end
          rescue Exception
            sleep 5
            next
          end
          break if response
        end
        raise Reve::Exceptions::ReveNetworkStatusException.new( (res.body rescue "No Response Body!") ) unless response
        
        xml = response
      
      # here ends test for URI
      elsif source.kind_of?(String)
        xml = File.open(source).read
      else
        raise Reve::Exceptions::ReveNetworkStatusException.new("Don't know how to deal with a #{source.class} XML source. I expect a URI or String")
      end
      @last_xml = xml

      xml
    end

    # Raises the proper exception (if there is one), otherwise it returns the
    # XML response.
    def check_exception(xml)
      x = Hpricot::XML(xml)
      begin
        out = x.search("//error") # If this fails then there are some big problems with Hpricot#search ?
      rescue Exception => e 
        $stderr.puts "Fatal error ((#{e.to_s})): Couldn't search the XML document ((#{xml})) for any potential error messages! Is your Hpricot broken?"
        exit 1
      end
      @current_time = (x/:currentTime).inner_html.to_time rescue Time.now.utc # Shouldn't need to rescue this but one never knows
      @cached_until = (x/:cachedUntil).inner_html.to_time rescue nil # Errors aren't always cached
      return x if out.size < 1
      code = out.first['code'].to_i
      str  = out.first.inner_html
      Reve::Exceptions.raise_it(code,str)
    end
    
    def save_xml(xml)
      path = build_save_filename
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path,'w') { |f| f.print xml.to_original_html }
    end
    
    def build_save_filename
      method = caller(3).first.match(/\`(.+)'/)[1] # Get the API method that's being called. This is called from save_xml -> process_query -> :real_method
      File.join(@save_path,@keyid.to_s,method,( @cached_until || Time.now.utc).to_i.to_s + '.xml')
    end

	# Returns an array of +klass+
	def pull_out_top_10_data(xml,klass,kind,field)
	  xml.search("/eveapi/result/#{kind}/rowset[@name='#{field}']/row").inject([]) do |all,row|
	    all << klass.new(row)
	    all
	  end
	end
  
  end
end
