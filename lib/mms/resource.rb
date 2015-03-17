module MMS

  class Resource

    attr_accessor :id
    attr_accessor :data

    attr_accessor :client

    # @param [MMS::Client] client
    def set_client(client)
      @client = client
    end

    # @param [Hash] data
    def set_data(data)
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
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [Array]
    def table_section
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [Array<String>]
    def self.table_header
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def _load(id)
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @param [Hash] data
    def _from_hash(data)
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    # @return [Hash]
    def _to_hash
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def invalidate_cache
      MMS::Cache.instance.delete(cache_key(@id))
    end

    # @param [MMS::Client] client
    # @param arguments...
    # @return self
    def self.find(client, *arguments)
      cache_key = self.cache_key(arguments.last())
      data = MMS::Cache.instance.get(cache_key)
      unless data
        data = self._find(client, *arguments)
      end

      resource = self.new
      resource.set_client(client)
      resource.set_data(data)
      resource
    end

    private

    def cache_key(id)
      "Class::#{self.class.name}:#{id}"
    end

    def self.cache_key(id)
      "Class::#{self.name}:#{id}"
    end

  end
end
