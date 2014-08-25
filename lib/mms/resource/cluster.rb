module MMS

  class Resource::Cluster < Resource

    attr_accessor :group

    def initialize(data)

    end

    def group_id
      @group.id
    end

    def group_name
      @group.name
    end

    def load_list
    end

    def load_one
    end
  end
end
