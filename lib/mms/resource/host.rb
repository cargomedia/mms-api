module MMS

  class Resource::Host < Resource

    attr_accessor :name
    attr_accessor :hostname
    attr_accessor :port
    attr_accessor :type_name
    attr_accessor :last_ping
    attr_accessor :ip_address
    attr_accessor :version
    attr_accessor :shard_name
    attr_accessor :replicaset_name
    attr_accessor :replica_state_name
    attr_accessor :alerts_enabled
    attr_accessor :host_enabled
    attr_accessor :profiler_enabled
    attr_accessor :logs_enabled

    def initialize
      @metric_list = []
    end

    # @return [MMS::Resource::Group]
    def group
      MMS::Resource::Group.find(@client, @data['groupId'])
    end

    def snapshot(id)
      MMS::Resource::Snapshot.find(@client, group.id, nil, @id, id)
    end

    def snapshots(page = 1, limit = 1000)
      if @snapshots.empty?
        @client.get('/groups/' + group.id + '/hosts/' + @id + '/snapshots?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |snapshot|
          s = MMS::Resource::Snapshot.new
          s.set_client(@client)
          s.set_data(snapshot)

          @snapshots.push s
        end
      end
      @snapshots
    end

    def table_row
      [group.name, @type_name, @name, @ip_address, @port, @last_ping, @alerts_enabled, @id, @shard_name, @replicaset_name]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Group', 'Type', 'Hostname', 'IP', 'Port', 'Last ping', 'Alerts enabled', 'HostId', 'Shard', 'Replica']
    end

    # @param [MMS::Client] client
    # @param [String] group_id
    # @param [String] id
    # @returns [Hash]
    def self._find(client, group_id, id)
      client.get('/groups/' + group_id + '/hosts/' + id)
    end

    # @returns [Array<MMS::Resource::Metric>]
    def metrics
      if @metric_list.empty?
        @client.get('/groups/' + group.id + '/hosts/' + @id + '/metrics').each do |metric|
          m = MMS::Resource::Metric.new
          m.set_client(@client)
          m.set_data(metric)

          @metric_list.push m
        end
      end
      @metric_list
    end

    private

    def _from_hash(data)
      @hostname = data['hostname']
      @port = data['port']
      @type_name = data['typeName']
      @last_ping = data['lastPing']
      @ip_address = data['ipAddress']
      @version = data['version']
      @shard_name = data['shardName']
      @replicaset_name = data['replicaSetName']
      @replica_state_name = data['replicaStateName']
      @alerts_enabled = data['alertsEnabled']
      @host_enabled = data['hostEnabled']
      @profiler_enabled = data['profilerEnabled']
      @logs_enabled = data['logsEnabled']
      @name = @hostname
    end

    def _to_hash
      @data
    end

  end
end
