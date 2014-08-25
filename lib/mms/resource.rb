module MMS

  class Resource

    attr_accessor :client

    attr_accessor :id
    attr_accessor :name
    attr_accessor :data

    def initialize(client, data = nil)
      @client = client
      @data = data

      from_hash(data)
    end

    def name
      @name
    end

    def id
      @id
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
