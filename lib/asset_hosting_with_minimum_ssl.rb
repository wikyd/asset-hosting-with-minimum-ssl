class AssetHostingWithMinimumSsl
  attr_accessor :asset_host, :ssl_asset_host
  attr_accessor :host_count
  
  def initialize(asset_host, ssl_asset_host, host_count = 4)
    self.asset_host, self.ssl_asset_host = asset_host, ssl_asset_host
    self.host_count = host_count
  end
  
  def call(source, request)
    if request && request.ssl?
      case
      when javascript_file?(source)
        ssl_asset_host(source)
      when safari?(request)
        asset_host(source)
      when firefox?(request) && image_file?(source)
        asset_host(source)
      else
        ssl_asset_host(source)
      end
    else
      asset_host(source)
    end
  end
  
  
  private
    # Consistently hash across different machines
    def host_number(source)
      Digest::MD5.hexdigest(source).to_i(16) % host_count
    end

    def asset_host(source)
      @asset_host % host_number(source)
    end

    def ssl_asset_host(source)
      @ssl_asset_host % host_number(source)
    end


    def javascript_file?(source)
      source =~ /\.js($|\?)/
    end
    
    def image_file?(source)
      source =~ /\.(png|jpe?g|gif)($|\?)/
    end

    def safari?(request)
      request.headers["USER_AGENT"] =~ /Safari/ && request.headers["USER_AGENT"] !~ /Chrome/
    end
    
    def firefox?(request)
      request.headers["USER_AGENT"] =~ /Firefox/
    end
end
