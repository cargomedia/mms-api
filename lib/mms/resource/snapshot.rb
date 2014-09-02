require 'date'

module MMS

  class Resource::Snapshot < Resource

    attr_accessor :name
    attr_accessor :cluster

    attr_accessor :complete
    attr_accessor :created_date
    attr_accessor :created_increment
    attr_accessor :expires
    attr_accessor :parts

    def initialize(id, cluster_id, group_id, data = nil)
      @cluster = MMS::Resource::Cluster.new cluster_id, group_id

      super id, data
    end

    def is_cluster
      @parts.length > 1
    end

    def is_config
      @parts.length == 1 and @parts.first['typeName'] == 'CONFIG_SERVER'
    end

    def is_replica
      @parts.length == 1 and @parts.first['typeName'] == 'REPLICA_SET'
    end

    def cluster_name
      @cluster.name if is_cluster
    end

    def config_name
      'config' if is_config
    end

    def replica_name
      @parts.first['replicaSetName'] if is_replica
    end

    def source_name
      name = nil
      name = replica_name if is_replica
      name = config_name if is_config
      name = cluster_name if is_cluster
      name
    end

    def create_restorejob
      data = {:snapshotId => @id}
      jobs = MMS::Client.instance.post '/groups/' + @cluster.group.id + '/clusters/' + @cluster.id + '/restoreJobs', data

      if jobs.nil?
        raise "Cannot create job from snapshot `#{self.id}`"
      end

      job_list = []
      # work around due to bug in MMS API; cannot read restoreJob using provided info.
      # The config-server RestoreJob and Snapshot has no own ClusterId to be accessed.
      restore_jobs = @cluster.restorejobs
      jobs.each do |job|
        _list = restore_jobs.select {|restorejob| restorejob.id == job['id'] }
        _list.each do |restorejob|
          job_list.push restorejob
        end
      end
      job_list
    end

    def _load(id)
      MMS::Client.instance.get '/groups/' + @cluster.group.id + '/clusters/' + @cluster.id + '/snapshots/' + id.to_s
    end

    def _from_hash(data)
      @complete = data['complete']
      @created_date = data['created']['date']
      @created_increment = data['created']['increment']
      @expires = data['expires']
      @parts = data['parts']
      @name = DateTime.parse(@created_date).strftime("%Y-%m-%d %H:%M:%S")

      @cluster = MMS::Resource::Cluster.new data['clusterId'], data['groupId']
    end
  end
end
