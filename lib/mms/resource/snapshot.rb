module MMS

  class Resource::Snapshot < Resource

    attr_accessor :name
    attr_accessor :cluster

    attr_accessor :complete
    attr_accessor :created_date
    attr_accessor :created_increment
    attr_accessor :expires
    attr_accessor :parts

    def initialize(id, cluster_id, group_id, data = nil)
      @cluster = MMS::Resource::Cluster.new cluster_id, group_id

      super id, data
    end

    def _load(id)
      MMS::Client.instance.get('/groups/' + @cluster.group.id + '/clusters/' + @cluster.id + '/snapshots/' + id.to_s)
    end

    def _from_hash(data)
      @complete = data['complete']
      @created_date = data['created']['date']
      @created_increment = data['created']['increment']
      @expires = data['expires']
      @parts = data['parts']
    end
  end
end
