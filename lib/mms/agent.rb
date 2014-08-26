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

    def snapshots
      MMS::Resource::Cluster.get_snapshots
    end

    def restorejobs
      MMS::Resource::Cluster.get_restore_jobs
    end

    def restorejobs_create(group_id, cluster_id, snapshot_id)
      begin
        cluster = MMS::Resource::Cluster.new cluster_id, group_id
        cluster.create_restorejob_from_snapshot snapshot_id
      rescue => e
        raise "Cannot create restore job `#{e.message}`"
      end
    end
  end
end
