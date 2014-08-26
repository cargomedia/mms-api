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
  end
end
