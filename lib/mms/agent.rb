module MMS
  class Agent
    attr_accessor :client

    # @param [MMS::Client] client
    def initialize(client)
      @client = client
    end

    # @param [String] apiurl
    def apiurl(apiurl)
      @client.url = apiurl
    end

    # @return [Array<MMS::Resource::Group>]
    def groups
      group_list = []
      client.get('/groups').each do |group|
        g = MMS::Resource::Group.new
        g.client(client)
        g.data(group)

        group_list.push g
      end
      group_list
    end

    # @return [Array<MMS::Resource::Host>]
    def hosts
      host_list = []
      groups.each do |group|
        host_list.concat group.hosts
      end
      host_list
    end

    # @param [String] groupid
    # @param [String] hostname
    # @param [Integer] port
    # @option options [String] username Required if authMechanismName is MONGODB_CR. Otherwise illegal.
    # @option options [String] password Required if authMechanismName is MONGODB_CR. Otherwise illegal.
    # @option options [TrueClass, FalseClass] sslEnabled Must be true if the authMechanismName is MONGODB_X509. Default is false if omitted.
    # @option options [TrueClass, FalseClass] logsEnabled Default is false if omitted.
    # @option options [TrueClass, FalseClass] alertsEnabled Default is true if omitted.
    # @option options [TrueClass, FalseClass] profilerEnabled Default is false if omitted.
    # @option options [Integer] muninPort Default is 0 and Munin stats are not collected if omitted.
    # @option options [String] authMechanismName Default is NONE if omitted. If set to MONGODB_CR then you must provide the username and password.
    # @return [<MMS::Resource::Host>]
    def host_create(groupid, hostname, port, options = {})
      data = {}
      data[:hostname] = hostname
      data[:port] = port
      data[:username] = options[:username] || nil
      data[:password] = options[:password] || nil
      data[:sslEnabled] = options[:sslEnabled] || false
      data[:logsEnabled] = options[:logsEnabled] || false
      data[:alertsEnabled] = options[:alertsEnabled] || true
      data[:profilerEnabled] = options[:profilerEnabled] || false
      data[:muninPort] = options[:muninPort] || 0
      data[:authMechanismName] = options[:authMechanismName] || nil
      ret_host = client.post("/groups/#{groupid}/hosts", data)
      host = MMS::Resource::Host.new
      host._from_hash(ret_host)
      host
    end

    # @param [String] groupid
    # @param [String] hostid
    # @option options [String] username Required if authMechanismName is MONGODB_CR. Otherwise illegal.
    # @option options [String] password Required if authMechanismName is MONGODB_CR. Otherwise illegal.
    # @option options [TrueClass, FalseClass] sslEnabled Must be true if the authMechanismName is MONGODB_X509. Default is false if omitted.
    # @option options [TrueClass, FalseClass] logsEnabled Default is false if omitted.
    # @option options [TrueClass, FalseClass] alertsEnabled Default is true if omitted.
    # @option options [TrueClass, FalseClass] profilerEnabled Default is false if omitted.
    # @option options [Integer] muninPort Default is 0 and Munin stats are not collected if omitted.
    # @option options [String] authMechanismName Default is NONE if omitted. If set to MONGODB_CR then you must provide the username and password.
    # @return [<MMS::Resource::Host>]
    def host_update(groupid, hostid, options = {})
      data = {}
      data[:username] = options[:username] if options.include?(:username)
      data[:password] = options[:password] if options.include?(:password)
      data[:sslEnabled] = options[:sslEnabled] if options.include?(:sslEnabled)
      data[:logsEnabled] = options[:logsEnabled] if options.include?(:logsEnabled)
      data[:alertsEnabled] = options[:alertsEnabled] if options.include?(:alertsEnabled)
      data[:profilerEnabled] = options[:profilerEnabled] if options.include?(:profilerEnabled)
      data[:muninPort] = options[:muninPort] if options.include?(:muninPort)
      data[:authMechanismName] = options[:authMechanismName] if options.include?(:authMechanismName)
      ret_host = client.patch("/groups/#{groupid}/hosts/#{hostid}", data)
      host = MMS::Resource::Host.new
      host._from_hash(ret_host)
      host
    end

    # @param [String] groupid
    # @param [String] hostid
    # @return [TrueClass, FalseClass]
    def host_delete(groupid, hostid)
      client.delete("/groups/#{groupid}/hosts/#{hostid}")
      host = client.delete("/groups/#{groupid}/hosts/#{hostid}")
      host == {} ? true : false
    end

    # @return [Array<MMS::Resource::Cluster>]
    def clusters
      cluster_list = []
      groups.each do |group|
        cluster_list.concat group.clusters
      end
      cluster_list
    end

    # @param [String] groupid
    # @param [String] clusterid
    # @param [String] name
    # @return [<MMS::Resource::Cluster>]
    def cluster_update(groupid, clusterid, name)
      data = { clusterName: name }
      ret_cluster = client.patch("/groups/#{groupid}/clusters/#{clusterid}", data)
      cluster = MMS::Resource::Cluster.new
      cluster._from_hash(ret_cluster)
      cluster
    end

    # @return [Array<MMS::Resource::Snapshot>]
    def snapshots
      snapshot_list = []
      clusters.each do |cluster|
        snapshot_list.concat cluster.snapshots
      end
      snapshot_list.sort_by(&:created_date).reverse
    end

    # @return [Array<MMS::Resource::Alert>]
    def alerts
      alert_list = []
      groups.each do |group|
        alert_list.concat group.alerts
      end
      alert_list.sort_by(&:created).reverse
    end

    # @return [Array<MMS::Resource::RestoreJob>]
    def restorejobs
      restorejob_list = []
      clusters.each do |cluster|
        restorejob_list.concat cluster.restorejobs
      end
      restorejob_list.sort_by(&:created).reverse
    end

    # @param [String] type_value
    # @param [String] group_id
    # @param [String] cluster_id
    # @return [Array<MMS::Resource::RestoreJob>]
    def restorejob_create(type_value, group_id, cluster_id)
      if type_value.length == 24
        find_group(group_id).cluster(cluster_id).snapshot(type_value).create_restorejob
      else
        datetime = (type_value == 'now' ? DateTime.now : DateTime.parse(type_value))
        fail('Invalid datetime. Correct `YYYY-MM-RRTH:m:sZ`') if datetime.nil?
        datetime_string = [[datetime.year, datetime.month, datetime.day].join('-'), 'T', [datetime.hour, datetime.minute, datetime.second].join(':'), 'Z'].join
        find_group(group_id).cluster(cluster_id).create_restorejob(datetime_string)
      end
    end

    # @param [String] alert_id
    # @param [String, Integer] timestamp
    # @param [String] group_id
    # @return [TrueClass, FalseClass]
    def alert_ack(alert_id, timestamp, group_id)
      timestamp = DateTime.now if timestamp == 'now'
      timestamp = DateTime.new(4000, 1, 1, 1, 1, 1, 1, 1) if timestamp == 'forever'

      group = find_group(group_id)

      if alert_id == 'all'
        group.alerts.each do |alert|
          alert.ack(timestamp, 'Triggered by CLI for all alerts.')
        end
      else
        group.alert(alert_id).ack(timestamp, 'Triggered by CLI.')
      end
    end

    # @param [String] id
    # @return [MMS::Resource::Group]
    def find_group(id)
      MMS::Resource::Group.find(@client, id)
    end
  end
end
