module MMS

  class Resource

    attr_accessor :id
    attr_accessor :name
    attr_accessor :data

    def initialize(id = nil, data = nil)
      @id = id
      @data = data

      from_hash(data)

      unless id.nil?
        MMS::Cache.instance.set "Class::#{self.class.name}:", self
      end
    end

    def to_hash
    end

    def from_hash(data)
      unless data.nil?
        @id = data['id']
        @name = data['name'] unless data['name'].nil?
      end
    end

    def load
    end
  end
end
