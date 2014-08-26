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

    def self.get_snapshots
      snapshot_list = []
      MMS::Resource::Group.get_clusters.each do |cluster|
        MMS::Client.instance.get('/groups/' + cluster.group.id + '/clusters/' + cluster.id + '/snapshots').each do |snapshot|
          snapshot_list.push MMS::Resource::Snapshot.new(snapshot['id'], snapshot['clusterId'], snapshot['groupId'], snapshot)
        end
      end
      snapshot_list
    end

    def self.get_restore_jobs
      job_list = []
      MMS::Resource::Group.get_clusters.each do |cluster|
        MMS::Client.instance.get('/groups/' + cluster.group.id + '/clusters/' + cluster.id + '/restoreJobs').each do |job|
          job_list.push MMS::Resource::RestoreJob.new(job['id'], job['snapshotId'], job['clusterId'], job['groupId'], job)
        end
      end
      job_list
    end

    def _load(id)
      MMS::Client.instance.get('/groups/' + @group.id + '/clusters/' + id.to_s)
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
