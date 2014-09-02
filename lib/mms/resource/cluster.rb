module MMS

  class Resource::Cluster < Resource

    attr_accessor :name
    attr_accessor :group
    attr_accessor :shard_name
    attr_accessor :replicaset_name
    attr_accessor :type_name
    attr_accessor :last_heartbeat

    attr_accessor :snapshots
    attr_accessor :restorejobs

    def initialize(id, group_id, data = nil)
      @snapshots = []
      @restorejobs = []

      @group = MMS::Resource::Group.new(group_id)

      super id, data
    end

    def snapshot(id)
      MMS::Resource::Snapshot.new id, @id, @group.id
    end

    def snapshots(page = 1, limit = 1000)
      if @snapshots.empty?
        MMS::Client.instance.get('/groups/' + @group.id + '/clusters/' + @id + '/snapshots?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |snapshot|
          @snapshots.push MMS::Resource::Snapshot.new(snapshot['id'], snapshot['clusterId'], snapshot['groupId'], snapshot)
        end
      end
      @snapshots
    end

    def restorejobs(page = 1, limit = 1000)
      if @restorejobs.empty?
        MMS::Client.instance.get('/groups/' + @group.id + '/clusters/' + @id + '/restoreJobs?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |job|
          @restorejobs.push MMS::Resource::RestoreJob.new(job['id'], job['clusterId'], job['groupId'], job)
        end
      end
      @restorejobs
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
