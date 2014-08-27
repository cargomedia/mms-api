module MMS

  class Agent

    def initialize(username, apikey)
      MMS::Client.instance.auth_setup(username, apikey)
    end

    def groups
      MMS::Resource::Group.load_list
    end

    def clusters
      MMS::Resource::Group.get_clusters
    end

    def snapshots(page = 1, limit = 10)
      MMS::Resource::Cluster.get_snapshots page, limit
    end

    def restorejobs(page = 1, limit = 10)
      MMS::Resource::Cluster.get_restore_jobs page, limit
    end

    def restorejobs_create(group_id, cluster_id, snapshot_id, page = 1, limit = 10)
      cluster = MMS::Resource::Cluster.new cluster_id, group_id
      cluster.create_restorejob_from_snapshot snapshot_id, page, limit
    end
  end
end
