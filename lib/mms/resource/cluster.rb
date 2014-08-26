module MMS

  class Resource::Cluster < Resource

    attr_accessor :name
    attr_accessor :group
    attr_accessor :shardName
    attr_accessor :replicaSetName
    attr_accessor :typeName
    attr_accessor :lastHeartbeat

    def initialize(id, group_id, data = nil)
      @group = MMS::Resource::Group.new(group_id)

      super id, data
    end

    def self.get_snapshots
      snapshot_list = []
      MMS::Resource::Group.get_clusters.each do |cluster|
        MMS::Client.instance.get('/groups/' + cluster.group.id + '/clusters/' + cluster.id + '/snapshots').each do |snapshot|
          snapshot_list.push MMS::Resource::Snapshot.new(snapshot['id'], snapshot['clusterId'], snapshot['groupId'], snapshot)
        end
      end
      snapshot_list
    end

    def self.get_restore_jobs(cluster = nil)

    end

    def _load(id)
      MMS::Client.instance.get('/groups/' + @group.id + '/clusters/' + id.to_s)
    end

    def _from_hash(data)
      @name = data['clusterName']
      @shardName = data['shardName']
      @replicaSetName = data['replicaSetName']
      @typeName = data['typeName']
      @lastHeartbeat = data['lastHeartbeat']
    end
  end
end
