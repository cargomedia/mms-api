module MMS

  class Agent

    def initialize(username, apikey)
      MMS::Client.instance.auth_setup(username, apikey)
    end

    def groups
      _findGroups
    end

    def clusters
      cluster_list = []
      groups.each do |group|
        cluster_list.concat group.clusters
      end
      cluster_list
    end

    def snapshots
      snapshot_list = []
      clusters.each do |cluster|
        snapshot_list.concat cluster.snapshots
      end
      snapshot_list
    end

    def restorejobs
      restorejob_list = []
      clusters.each do |cluster|
        restorejob_list.concat cluster.restorejobs
      end
      restorejob_list
    end

    def restorejobs_create(group_id, cluster_id, snapshot_id)
      snapshot = MMS::Resource::Snapshot.new snapshot_id, cluster_id, group_id
      snapshot.create_restorejob
    end

    private

    def _findGroups(page = 1, limit = 1000)
      group_list = []
      MMS::Client.instance.get('/groups?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |group|
        group_list.push MMS::Resource::Group.new(group['id'], group)
      end
      group_list
    end

  end
end
