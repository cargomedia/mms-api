module MMS

  class Resource

    attr_accessor :id
    attr_accessor :data

    def initialize(id, data = nil)
      @id = id
      @data = data

      load
    end

    def from_hash(data)
      unless data.nil?
        @id = data['id']
        _from_hash data
      end
    end

    def reload
      @data = _load(@id)
      save @data unless @data.nil? or @data.empty?
    end

    def load
      _data = MMS::Cache.instance.get "Class::#{self.class.name}:#{@id}"

      if _data.nil? and @data.nil?
        _data = _load(@id) unless @id.nil?

        if _data.nil?
          raise "Cannot load data for #{self.class.name}, id `#{@id}`"
        end
      end

      save _data || @data
    end

    def save(data)
      from_hash data
      MMS::Cache.instance.set "Class::#{self.class.name}:#{@id}", data
    end

    def table_row
      raise("`#{__method__}` is not implemented for `#{self.class.name}`")
    end

    def table_section
      raise("`#{__method__}` Not implemented for `#{self.class.name}`")
    end

    def self.table_header
      raise("`#{__method__}` Not implemented for `#{self.class.name}`")
    end

    def _load(id)
      raise("`#{__method__}` Not implemented for `#{self.class.name}`")
    end

    def _from_hash(data)
      raise("`#{__method__}` Not implemented for `#{self.class.name}`")
    end
  end
end
