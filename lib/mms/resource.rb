module MMS
  class Resource
    attr_accessor :id
    attr_accessor :data

    attr_accessor :client
    attr_writer :client

    # @param [MMS::Client] client
    def client(client)
      @client = client
    end

    # @param [Hash] data
    def data(data)
      @data = data
      from_hash(data)
      MMS::Cache.instance.set(cache_key(@id), data)
    end

    # @param [Hash] data
    def from_hash(data)
      unless data.nil?
        @id = data['id']
        _from_hash data
      end
    end

    def to_hash
      _to_hash
    end

    # @return [Array<String>]
    def table_row
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [Array]
    def table_section
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [Array<String>]
    def self.table_header
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def _load(_id)
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @param [Hash] data
    def _from_hash(_data)
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [Hash]
    def _to_hash
      fail("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def invalidate_cache
      MMS::Cache.instance.delete(cache_key(@id))
    end

    # @param [MMS::Client] client
    # @param arguments...
    # @return self
    def self.find(client, *arguments)
      cache_key = self.cache_key(arguments.last)
      data = MMS::Cache.instance.get(cache_key)

      data = _find(client, *arguments) unless data

      resource = new
      resource.client(client)
      resource.data(data)
      resource
    end

    private

    def cache_key(id)
      "Class::#{self.class.name}:#{id}"
    end

    def self.cache_key(id)
      "Class::#{name}:#{id}"
    end
  end
end
