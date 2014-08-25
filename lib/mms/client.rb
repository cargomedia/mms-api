require 'singleton'

module MMS

  class Client

    include Singleton

    attr_accessor :site
    attr_accessor :username
    attr_accessor :apikey

    def initialize
      @site, @username, @apikey = nil
    end

    def setup(site, username, apikey)
      @site = site
      @username = username
      @apikey = apikey
    end

    def get(path)
      MMS::Helper.get @site + path, @username, @apikey
    end
  end
end
