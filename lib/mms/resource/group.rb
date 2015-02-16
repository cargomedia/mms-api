module MMS

  class Resource::Group < Resource

    attr_reader :name
    attr_reader :active_agent_count
    attr_reader :replicaset_count
    attr_reader :shard_count
    attr_reader :last_active_agent

    attr_accessor :clusters

    def initialize
      @clusters = []

    end

    def hosts(page = 1, limit = 10)
      host_list = []
      @client.get('/groups/' + @id + '/hosts?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |host|
        h = MMS::Resource::Host.new
        h.set_client(@client)
        h.set_data(host)

        host_list.push h
      end
      host_list
    end

    def alerts(page = 1, limit = 10, status = 'OPEN')
      alert_list = []
      @client.get('/groups/' + @id + '/alerts?status=' + status + '&pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |alert|
        a = MMS::Resource::Alert.new
        a.set_client(@client)
        a.set_group(self)
        a.set_data(data)

        alert_list.push a
      end
      alert_list
    end

    def alert(id)
      MMS::Resource::Alert.find(@client, @id, id)
    end

    def clusters(page = 1, limit = 10)
      if @clusters.empty?
        @client.get('/groups/' + @id + '/clusters?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |cluster|
          c = MMS::Resource::Cluster.new
          c.set_client(@client)
          c.set_data(cluster)
          @clusters.push c
        end
      end
      @clusters
    end

    def cluster(id)
      MMS::Resource::Cluster.find(@client, @id, id)
    end

    def find_snapshot(id)
      snapshot = nil
      clusters.each do |cluster|
        begin
          snapshot = cluster.snapshot(id)
        rescue => e
          # STDERR.puts 'cannot load snapshotId for cluster if config-server is the source!'
          # STDERR.puts 'not supported in current MMS API version'
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

    def self._find(client, id)
      client.get('/groups/' + id)
    end

    private

    def _from_hash(data)
      @name = data['name']
      @active_agent_count = data['activeAgentCount']
      @replicaset_count = data['replicaSetCount']
      @shard_count = data['shardCount']
      @last_active_agent = data['lastActiveAgent']
    end

    def _to_hash
      @data
    end
  end
end
