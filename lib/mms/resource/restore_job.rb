require 'date'

module MMS

  class Resource::RestoreJob < Resource

    attr_accessor :name

    # this is source point from where RestoreJob was created
    # RestoreJob.snapshot.cluster is e.g replica, config server
    # RestoreJob.cluster is full cluster group (configs, replicas)
    attr_accessor :snapshot

    attr_accessor :snapshot_id
    attr_accessor :timestamp
    attr_accessor :created
    attr_accessor :status_name
    attr_accessor :point_in_time
    attr_accessor :delivery_method_name
    attr_accessor :delivery_status_name
    attr_accessor :delivery_url

    def cluster
      begin
        cluster = MMS::Resource::Cluster.find(@client, @data['groupId'], @data['clusterId'])
      rescue
        # Workaround
        # time to time the mms-api return data without "clusterId" defined
        # creation of empty clluster instance is a good solution here.
        cluster = MMS::Resource::Cluster.new
        cluster.set_client(@client)
        cluster.set_data({'groupId' => @data['groupId']})
      end
      cluster
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
        @snapshot = cluster.group.find_snapshot(@snapshot_id)
      end
      @snapshot
    end

    def table_row
      time_str = DateTime.parse(@timestamp).strftime("%m/%d/%Y %H:%M")
      [time_str, @snapshot_id, @name, @status_name, @point_in_time, @delivery_method_name, @delivery_status_name]
    end

    def table_section
      [
          table_row,
          [@id, "#{cluster.name} (#{cluster.id})", {:value => '', :colspan => 5}],
          ['', cluster.group.name, {:value => '', :colspan => 5}],
          [{:value => 'download url:', :colspan => 7}],
          [{:value => @delivery_url || '(waiting for link)', :colspan => 7}],
          :separator
      ]
    end

    def self.table_header
      ['Timestamp / RestoreId', 'SnapshotId / Cluster / Group', 'Name (created)', 'Status', 'Point in time', 'Delivery', 'Restore status']
    end

    def self.find_recursively(client, group_id, cluster_id, id)
      cluster = MMS::Resource::Cluster.find(client, group_id, cluster_id)
      # config server has no cluster but owns RestoreJob and Snapshot
      restore_jobs = cluster.restorejobs
      job = restore_jobs.select { |restorejob| restorejob.id == id }
      job.first.data unless job.nil? and job.empty?
    end

    def self._find(client, group_id, cluster_id, id)
      client.get('/groups/' + group_id + '/clusters/' + cluster_id + '/restoreJobs/' + id)
    end

    private

    def _from_hash(data)
      @snapshot_id = data['snapshotId']
      @created = data['created']
      @status_name = data['statusName']
      @timestamp = data['timestamp']['date']
      @point_in_time = data['pointInTime']
      @delivery_method_name = data['delivery']['methodName'] unless data['delivery'].nil?
      @delivery_status_name = data['delivery']['statusName'] unless data['delivery'].nil?
      @delivery_url = data['delivery']['url'] unless data['delivery'].nil?
      @name = DateTime.parse(@created).strftime("%Y-%m-%d %H:%M:%S")
    end

    def _to_hash
      @data
    end
  end
end
