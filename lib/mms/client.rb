module MMS

  class Client

    attr_accessor :site
    attr_accessor :username
    attr_accessor :apikey

    def initialize(site, username, apikey)
      @site = site
      @username = username
      @apikey = apikey
    end

    def get(path)
      MMS::Helper.get @site + path, @username, @apikey
    end
  end
end
