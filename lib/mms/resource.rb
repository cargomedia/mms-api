module MMS

  class Resource

    attr_accessor :id
    attr_accessor :data

    attr_accessor :client

    def set_client(client)
      @client = client
    end

    def set_data(data)
      @data = data
      from_hash(data)
      cache_key = "Class::#{self.class.name}:#{@id}"
      MMS::Cache.instance.set(cache_key, data)
    end

    def from_hash(data)
      unless data.nil?
        @id = data['id']
        _from_hash data
      end
    end

    def to_hash
      _to_hash
    end

    def table_row
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def table_section
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def self.table_header
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def _load(id)
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def _from_hash(data)
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def _to_hash
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def self.find(client, *arguments)
      cache_key = "Class::#{self.name}:#{arguments.last()}"
      data = MMS::Cache.instance.get(cache_key)
      unless data
        data = self._find(client, *arguments)
      end

      resource = self.new
      resource.set_client(client)
      resource.set_data(data)
      resource
    end
  end
end
