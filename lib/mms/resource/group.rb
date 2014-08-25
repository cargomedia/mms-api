module MMS

  class Resource::Group < Resource

    attr_accessor :name
    attr_accessor :activeAgentCount
    attr_accessor :replicaSetCount
    attr_accessor :shardCount
    attr_accessor :lastActiveAgent

    def initialize(id, data = nil)
      super id, data
    end

    def self.load_list
      group_list = []
      MMS::Client.instance.get('/groups').each do |group|
        group_list.push MMS::Resource::Group.new(group['id'], group)
      end
      group_list
    end

    def _load(id)
      MMS::Client.instance.get('/groups/' + id.to_s)
    end

    def _from_hash(data)
      @name = data['name']
      @activeAgentCount = data['activeAgentCount']
      @replicaSetCount = data['replicaSetCount']
      @shardCount = data['shardCount']
      @lastActiveAgent = data['lastActiveAgent']
    end
  end
end
