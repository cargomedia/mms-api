require 'singleton'

module MMS

  class Cache

    include Singleton

    attr_accessor :storage

    def initialize
      @storage = Hash.new {|hash, key| hash[key] = {} }
    end

    def set(key, value)
      @storage[key] = value
    end

    def get(key)
      @storage[key]
    end

    def storage
      @storage
    end
  end
end
