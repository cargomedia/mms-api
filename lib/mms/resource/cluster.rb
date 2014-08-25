module MMS

  class Resource::Cluster < Resource

    attr_accessor :group

    def initialize(id, data = nil)
    end

    def self.load_list
      []
    end

    def _load(id)
    end

    def _from_hash(data)
    end
  end
end
