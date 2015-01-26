module MMS

  class Resource::Host < Resource

    @client = nil

    attr_accessor :name
    attr_accessor :group
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

    def initialize(client, data)
      id = data['id']
      group_id = data['groupId']

      raise('`Id` for host resource must be defined') if id.nil?
      raise('`groupId` for host resource must be defined') if group_id.nil?

      @client = client

      @group = MMS::Resource::Group.new(client, {'id' => group_id})

      super id, data
    end

    def table_row
      [@group.name, @type_name, @name, @ip_address, @port, @last_ping, @alerts_enabled, @id, @shard_name, @replicaset_name]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Group', 'Type', 'Hostname', 'IP', 'Port', 'Last ping', 'Alerts enabled', 'HostId', 'Shard', 'Replica']
    end

    private

    def _load(id)
      @client.get '/groups/' + @group.id + '/hosts/' + id.to_s
    end

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
  end
end
