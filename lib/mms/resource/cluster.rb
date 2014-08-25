module MMS

  class Resource::Cluster < Resource

    attr_reader   :name
    attr_reader   :group
    attr_accessor :shardName
    attr_accessor :replicaSetName
    attr_accessor :typeName
    attr_accessor :lastHeartbeat

    def initialize(id, data = nil)
      super id, data
    end

    def self.get_snapshots(cluster = nil)

    end

    def self.get_restore_jobs(cluster = nil)

    end

    def _load(id, group_id)
      MMS::Client.instance.get('/groups/' + group_id.to_s + '/clusters/' + id.to_s)
    end

    def _from_hash(data)
      @name = data['clusterName']
      @shardName = data['shardName']
      @replicaSetName = data['replicaSetName']
      @typeName = data['typeName']
      @lastHeartbeat = data['lastHeartbeat']
      @group = MMS::Resource::Group.new(data['groupId'])
    end
  end
end
