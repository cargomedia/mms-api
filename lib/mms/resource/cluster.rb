module MMS

  class Resource::Cluster < Resource

    attr_accessor :name
    attr_accessor :group
    attr_accessor :shard_name
    attr_accessor :replicaset_name
    attr_accessor :type_name
    attr_accessor :last_heartbeat

    def initialize(id, group_id, data = nil)
      @group = MMS::Resource::Group.new(group_id)

      super id, data
    end

    def snapshot(id)
      MMS::Resource::Snapshot.new id, self.id, self.group.id
    end

    def snapshots(page = 1, limit = 1000)
      snapshot_list = []
      MMS::Client.instance.get('/groups/' + @group.id + '/clusters/' + @id + '/snapshots?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |snapshot|
        snapshot_list.push MMS::Resource::Snapshot.new(snapshot['id'], snapshot['clusterId'], snapshot['groupId'], snapshot)
      end
      snapshot_list
    end

    def restorejobs(page = 1, limit = 1000)
      job_list = []
      MMS::Client.instance.get('/groups/' + @group.id + '/clusters/' + @id + '/restoreJobs?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |job|
        job_list.push MMS::Resource::RestoreJob.new(job['id'], job['clusterId'], job['groupId'], job)
      end
      job_list
    end

    def _load(id)
      MMS::Client.instance.get '/groups/' + @group.id + '/clusters/' + id.to_s
    end

    def _from_hash(data)
      @name = data['clusterName']
      @shard_name = data['shardName']
      @replicaset_name = data['replicaSetName']
      @type_name = data['typeName']
      @last_heartbeat = data['lastHeartbeat']
    end
  end
end
