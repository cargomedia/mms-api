module MMS

  class Resource::RestoreJob < Resource

    attr_accessor :name
    attr_accessor :cluster

    attr_accessor :snapshot_id
    attr_accessor :created
    attr_accessor :status_name
    attr_accessor :point_in_time
    attr_accessor :delivery_method_name
    attr_accessor :delivery_status_name
    attr_accessor :delivery_url

    def initialize(id, cluster_id, group_id, data = nil)
      @cluster = MMS::Resource::Cluster.new cluster_id, group_id

      super id, data
    end

    def _load(id)
      MMS::Client.instance.get '/groups/' + @cluster.group.id + '/clusters/' + @cluster.id + '/restoreJobs/' + id.to_s
    end

    def _from_hash(data)
      @snapshot_id = data['snapshotId']
      @created = data['created']
      @status_name = data['statusName']
      @point_in_time = data['pointInTime']
      @delivery_method_name = data['delivery']['methodName']
      @delivery_status_name = data['delivery']['statusName']
      @delivery_url = data['delivery']['url']
      @name = @created
    end
  end
end
