require 'singleton'

module MMS

  class Cache

    include Singleton

    attr_accessor :storage

    def initialize
      @storage = Hash.new {|hash, key| hash[key] = nil }
    end

    # @param [String] key
    # @param [Object] value
    def set(key, value)
      @storage[key] = value
    end

    # @param [String] key
    # @return [Object]
    def get(key)
      @storage[key].nil? ? nil : @storage[key]
    end

    # @param [String] key
    def delete(key)
      @storage.delete key unless @storage[key].nil?
    end

    def clear
      initialize
    end

    def storage
      @storage
    end
  end
end
