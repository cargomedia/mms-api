require 'date'

module MMS
  class Resource::Snapshot < Resource
    attr_accessor :name

    attr_accessor :complete
    attr_accessor :created_date
    attr_accessor :created_increment
    attr_accessor :expires
    attr_accessor :parts
    attr_accessor :is_possibly_inconsistent

    # @return [TrueClass, FalseClass]
    def is_cluster
      @parts.length > 1
    end

    # @return [TrueClass, FalseClass]
    def is_config
      @parts.length == 1 && @parts.first['typeName'] == 'REPLICA_SET' && !@parts.first['hostId'].nil?
    end

    # @return [TrueClass, FalseClass]
    def is_replica
      @parts.length == 1 && @parts.first['typeName'] == 'REPLICA_SET' && !@parts.first['clusterId'].nil?
    end

    # @return [String, NilClass]
    def cluster_name
      cluster.name if is_cluster
    end

    # @return [String, NilClass]
    def config_name
      'config' if is_config
    end

    # @return [String, NilClass]
    def replica_name
      @parts.first['replicaSetName'] if is_replica
    end

    # @return [String, NilClass]
    def source_name
      name = nil
      name = replica_name if is_replica
      name = config_name if is_config
      name = cluster_name if is_cluster
      name
    end

    # @return [MMS::Resource::Cluster]
    def cluster
      MMS::Resource::Cluster.find(@client, @data['groupId'], @data['clusterId'])
    end

    # @return [Array<MMS::Resource::RestoreJob>]
    def create_restorejob
      data = { snapshotId: @id }
      job_data_list = @client.post '/groups/' + cluster.group.id + '/clusters/' + cluster.id + '/restoreJobs', data

      if job_data_list.nil?
        raise MMS::ResourceError.new("Cannot create job from snapshot `#{id}`", self)
      end

      job_data_list.map do |job_data|
        j = MMS::Resource::RestoreJob.new
        j.client(@client)
        j.data(job_data)
        j
      end
    end

    def table_row
      [cluster.group.name, cluster.name, @id, @complete, @created_increment, @name, @expires, @is_possibly_inconsistent]
    end

    def table_section
      rows = []
      rows << table_row
      rows << :separator
      part_count = 0
      @parts.each do |part|
        file_size_mb = part['fileSizeBytes'].to_i / (1024 * 1024)
        rows << [{ value: "part #{part_count}", colspan: 4, alignment: :right }, part['typeName'], part['replicaSetName'], "#{file_size_mb} MB"]
        part_count += 1
      end
      rows << :separator
      rows
    end

    def self.table_header
      ['Group', 'Cluster', 'SnapshotId', 'Complete', 'Created increment', 'Name (created date)', 'Expires', 'Inconsistent']
    end

    # @param [MMS::Client] client
    # @param [String] group_id
    # @param [String] cluster_id
    # @param [String] id
    # @return [MMS::Resource::Snapshot]
    def self._find(client, group_id, cluster_id, host_id, id)
      host_id.nil? ? _find_by_cluster(client, group_id, cluster_id, id) : _find_by_host(client, group_id, host_id, id)
    end

    def self._find_by_cluster(client, group_id, cluster_id, id)
      client.get('/groups/' + group_id + '/clusters/' + cluster_id + '/snapshots/' + id.to_s)
    end

    def self._find_by_host(client, group_id, host_id, id)
      client.get('/groups/' + group_id + '/hosts/' + host_id + '/snapshots/' + id.to_s)
    end

    private

    def _from_hash(data)
      @complete = data['complete']
      @created_date = data['created'].nil? ? nil : data['created']['date']
      @created_increment = data['created'].nil? ? nil : data['created']['increment']
      @expires = data['expires']
      @parts = data['parts']
      @is_possibly_inconsistent = data['isPossiblyInconsistent']
      @name = @created_date.nil? ? @id : DateTime.parse(@created_date).strftime('%Y-%m-%d %H:%M:%S')
    end

    def _to_hash
      @data
    end
  end
end
