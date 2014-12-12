module MMS

  class Resource::Group < Resource

    attr_reader :name
    attr_reader :active_agent_count
    attr_reader :replicaset_count
    attr_reader :shard_count
    attr_reader :last_active_agent

    attr_accessor :clusters

    def initialize(data)
      id = data['id']

      raise('`Id` for group resource must be defined') if id.nil?

      @clusters = []

      super id, data
    end

    def hosts(page = 1, limit = 1000)
      host_list = []
      MMS::Client.instance.get('/groups/' + @id + '/hosts?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |host|
        host_list.push MMS::Resource::Host.new(host)
      end
      host_list
    end

    def alerts(page = 1, limit = 1000, status = 'OPEN')
      alert_list = []
      MMS::Client.instance.get('/groups/' + @id + '/alerts?status=' + status + '&pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |alert|
        alert_list.push MMS::Resource::Alert.new(alert)
      end
      alert_list
    end

    def alert(id)
      MMS::Resource::Alert.new({'id' => id, 'groupId' => @id})
    end

    def clusters(page = 1, limit = 1000)
      if @clusters.empty?
        MMS::Client.instance.get('/groups/' + @id + '/clusters?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |cluster|
          @clusters.push MMS::Resource::Cluster.new(cluster)
        end
      end
      @clusters
    end

    def cluster(id)
      MMS::Resource::Cluster.new({'id' => id, 'groupId' => @id})
    end

    def findSnapshot(id)
      snapshot = nil
      clusters.each do |cluster|
        begin
          snapshot = cluster.snapshot(id)
        rescue => e
          # cannot load snapshotId for cluster if config-server is the source?
          # not supported in current MMS API version
        end
      end
      snapshot
    end

    def table_row
      [@name, @active_agent_count, @replicaset_count, @shard_count, @last_active_agent, @id]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Name', 'Active Agents', 'Replicas count', 'Shards count', 'Last Active Agent', 'GroupId']
    end

    private

    def _load(id)
      MMS::Client.instance.get '/groups/' + id.to_s
    end

    def _from_hash(data)
      @name = data['name']
      @active_agent_count = data['activeAgentCount']
      @replicaset_count = data['replicaSetCount']
      @shard_count = data['shardCount']
      @last_active_agent = data['lastActiveAgent']
    end
  end
end
