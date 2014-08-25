require 'singleton'

module MMS

  class Cache

    include Singleton

    attr_accessor :storage

    def initialize
      @storage = Hash.new {|hash, key| hash[key] = nil }
    end

    def set(key, value)
      @storage[key] = value
    end

    def get(key)
      @storage[key].nil? ? nil : @storage[key]
    end

    def delete(key)
      @storage.delete key unless @storage[key].nil?
    end

    def storage
      @storage
    end
  end
end
