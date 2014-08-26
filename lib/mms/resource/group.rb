module MMS

  class Resource::Group < Resource

    attr_reader :name
    attr_reader :activeAgentCount
    attr_reader :replicaSetCount
    attr_reader :shardCount
    attr_reader :lastActiveAgent

    def initialize(id, data = nil)
      super id, data
    end

    def self.get_clusters
      cluster_list = []
      load_list.each do |group|
        MMS::Client.instance.get('/groups/' + group.id + '/clusters').each do |cluster|
          cluster_list.push MMS::Resource::Cluster.new(cluster['id'], cluster['groupId'], cluster)
        end
      end
      cluster_list
    end

    def get_cluster(id)
      MMS::Resource::Cluster.new(id, self.id)
    end

    def self.load_list
      group_list = []
      MMS::Client.instance.get('/groups').each do |group|
        group_list.push MMS::Resource::Group.new(group['id'], group)
      end
      group_list
    end

    def _load(id)
      MMS::Client.instance.get('/groups/' + id.to_s)
    end

    def _from_hash(data)
      @name = data['name']
      @activeAgentCount = data['activeAgentCount']
      @replicaSetCount = data['replicaSetCount']
      @shardCount = data['shardCount']
      @lastActiveAgent = data['lastActiveAgent']
    end
  end
end
