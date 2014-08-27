module MMS

  class Resource::Group < Resource

    attr_reader :name
    attr_reader :active_agent_count
    attr_reader :replicaset_count
    attr_reader :shard_count
    attr_reader :last_active_agent

    def initialize(id, data = nil)
      super id, data
    end

    def clusters(page = 1, limit = 1000)
      cluster_list = []
      MMS::Client.instance.get('/groups/' + @id + '/clusters?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |cluster|
        cluster_list.push MMS::Resource::Cluster.new(cluster['id'], cluster['groupId'], cluster)
      end
      cluster_list
    end

    def cluster(id)
      MMS::Resource::Cluster.new id, self.id
    end

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
