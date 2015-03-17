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

    attr_accessor :cluster_id
    attr_accessor :group_id

    # @return [MMS::Resource::Cluster]
    def cluster
      MMS::Resource::Cluster.find(@client, @group_id, @cluster_id)
    end

    # @return [MMS::Resource::Snapshot, NilClass]
    def snapshot
      @snapshot ||= cluster.group.find_snapshot(@snapshot_id)
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

    def self._find(client, group_id, cluster_id, id)
      begin
        client.get('/groups/' + group_id + '/clusters/' + cluster_id + '/restoreJobs/' + id)
      rescue MMS::ApiError => e
        # workaround for https://jira.mongodb.org/browse/DOCS-5017
        self._find_from_list(client, group_id, cluster_id, id)
      end
    end

    def self._find_from_list(client, group_id, cluster_id, id)
      cluster = MMS::Resource::Cluster.find(client, group_id, cluster_id)

      job = cluster.restorejobs.find { |restorejob| restorejob.id == id }
      raise("Cannot find RestoreJob id `#{id}`") if job.nil?

      job.data
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
      @cluster_id = data['clusterId']
      @group_id = data['groupId']
    end

    def _to_hash
      @data
    end
  end
end
