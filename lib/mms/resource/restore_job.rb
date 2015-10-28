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
    attr_accessor :host_id
    attr_accessor :hashes

    # @return [MMS::Resource::Cluster]
    def cluster
      MMS::Resource::Cluster.find(@client, @group_id, @cluster_id)
    end

    def host
      MMS::Resource::Host.find(@client, @group_id, @host_id)
    end

    def has_host?
      !@host_id.nil?
    end

    # @return [MMS::Resource::Snapshot, NilClass]
    def snapshot
      has_host? ? host.snapshot(@snapshot_id) : cluster.snapshot(@snapshot_id)
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

    def self._find(client, group_id, cluster_id, host_id, id)
      host_id.nil? ? self._find_by_cluster(client, group_id, cluster_id, id) : self._find_by_host(client, group_id, host_id, id)
    end

    def self._find_by_host(client, group_id, host_id, id)
      client.get('/groups/' + group_id + '/hosts/' + host_id + '/restoreJobs/' + id)
    end

    def self._find_by_cluster(client, group_id, cluster_id, id)
      client.get('/groups/' + group_id + '/clusters/' + cluster_id + '/restoreJobs/' + id)
    end

    private

    def _from_hash(data)
      puts '--- DEBUG FROM HASH ------------------------------------------------------------'
      puts data.inspect
      puts '--- DEBUG FROM HASH ------------------------------------------------------------'
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
      @host_id = data['hostId']
      @hashes = data['hashes']
    end

    def _to_hash
      @data
    end
  end
end
