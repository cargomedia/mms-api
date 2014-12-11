require 'date'

module MMS

  class Resource::RestoreJob < Resource

    attr_accessor :name

    # this is restore point cluster e.g full cluster (configs, replicas)
    attr_accessor :cluster

    # this is source point from where RestoreJob was created
    # RestoreJob.snapshot.cluster is e.g replica, config server
    # RestoreJob.cluster is full cluster group (configs, replicas)
    attr_accessor :snapshot

    attr_accessor :snapshot_id
    attr_accessor :created
    attr_accessor :status_name
    attr_accessor :point_in_time
    attr_accessor :delivery_method_name
    attr_accessor :delivery_status_name
    attr_accessor :delivery_url

    def initialize(id, cluster_id, group_id, data = nil)
      @cluster = MMS::Resource::Cluster.new cluster_id, group_id

      super id, data
    end

    def has_cluster
      # cluster definition for config-server cannot be loaded
      # as there is no clusterId for this type of group.
      # there is snapshotId for RestoreJob but seems to be stored
      # internally in MMS API. Not accessible by public API.
      snapshot != nil
    end

    def snapshot
      # snapshot details for config-server cannot be loaded
      # as there is no clusterId. See also has_cluster()
      if @snapshot.nil?
        @snapshot = @cluster.group.findSnapshot(@snapshot_id)
      end
      @snapshot
    end

    def table_row
      [@id, @snapshot_id, @name, @status_name, @point_in_time, @delivery_method_name, @delivery_status_name]
    end

    def table_section
      [
          table_row,
          ['', "#{@cluster.name} (#{@cluster.id})", {:value => '', :colspan => 5}],
          ['', @cluster.group.name, {:value => '', :colspan => 5}],
          [{:value => 'download url:', :colspan => 7}],
          [{:value => @delivery_url || '(waiting for link)', :colspan => 7}],
          :separator
      ]
    end

    def self.table_header
      ['RestoreId', 'SnapshotId / Cluster / Group', 'Name (created)', 'Status', 'Point in time', 'Delivery', 'Restore status']
    end

    private

    def _load(id)
      if has_cluster
        data = MMS::Client.instance.get '/groups/' + snapshot.cluster.group.id + '/clusters/' + snapshot.cluster.id + '/restoreJobs/' + id.to_s
      else
        # config server has no cluster but owns RestoreJob and Snapshot
        restore_jobs = @cluster.restorejobs
        job = restore_jobs.select { |restorejob| restorejob.id == id }
        data = job.first.data unless job.nil? and job.empty?
      end
      data
    end

    def _from_hash(data)
      @snapshot_id = data['snapshotId']
      @created = data['created']
      @status_name = data['statusName']
      @point_in_time = data['pointInTime']
      @delivery_method_name = data['delivery']['methodName'] unless data['delivery'].nil?
      @delivery_status_name = data['delivery']['statusName'] unless data['delivery'].nil?
      @delivery_url = data['delivery']['url'] unless data['delivery'].nil?
      @name = DateTime.parse(@created).strftime("%Y-%m-%d %H:%M:%S")
    end
  end
end
