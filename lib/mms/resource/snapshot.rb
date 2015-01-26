require 'date'

module MMS

  class Resource::Snapshot < Resource

    @client = nil

    attr_accessor :name
    attr_accessor :cluster

    attr_accessor :complete
    attr_accessor :created_date
    attr_accessor :created_increment
    attr_accessor :expires
    attr_accessor :parts

    def initialize(client, data)
      id = data['id']
      cluster_id = data['clusterId']
      group_id = data['groupId']

      raise('`Id` for restorejob resource must be defined') if id.nil?
      raise('`clusterId` for restorejob resource must be defined') if cluster_id.nil?
      raise('`groupId` for restorejob resource must be defined') if group_id.nil?

      @client = client

      @cluster = MMS::Resource::Cluster.new(client, {'id' => cluster_id, 'groupId' => group_id})

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
      jobs = @client.post '/groups/' + @cluster.group.id + '/clusters/' + @cluster.id + '/restoreJobs', data

      if jobs.nil?
        raise "Cannot create job from snapshot `#{self.id}`"
      end

      job_list = []
      # work around due to bug in MMS API; cannot read restoreJob using provided info.
      # The config-server RestoreJob and Snapshot has no own ClusterId to be accessed.
      restore_jobs = @cluster.restorejobs
      jobs.each do |job|
        _list = restore_jobs.select { |restorejob| restorejob.id == job['id'] }
        _list.each do |restorejob|
          job_list.push restorejob
        end
      end
      job_list
    end

    def table_row
      [@cluster.group.name, @cluster.name, @id, @complete, @created_increment, @name, @expires]
    end

    def table_section
      rows = []
      rows << table_row
      rows << :separator
      part_count = 0
      @parts.each do |part|
        file_size_mb = part['fileSizeBytes'].to_i / (1024*1024)
        rows << [{:value => "part #{part_count}", :colspan => 4, :alignment => :right}, part['typeName'], part['replicaSetName'], "#{file_size_mb} MB"]
        part_count += 1
      end
      rows << :separator
      rows
    end

    def self.table_header
      ['Group', 'Cluster', 'SnapshotId', 'Complete', 'Created increment', 'Name (created date)', 'Expires']
    end

    private

    def _load(id)
      @client.get '/groups/' + @cluster.group.id + '/clusters/' + @cluster.id + '/snapshots/' + id.to_s
    end

    def _from_hash(data)
      @complete = data['complete']
      @created_date = data['created']['date']
      @created_increment = data['created']['increment']
      @expires = data['expires']
      @parts = data['parts']
      @name = DateTime.parse(@created_date).strftime("%Y-%m-%d %H:%M:%S")

      @cluster = MMS::Resource::Cluster.new(@client, {'id' => data['clusterId'], 'groupId' => data['groupId']})
    end
  end
end
