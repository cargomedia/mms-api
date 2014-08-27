module MMS

  class Agent

    def initialize(username, apikey)
      MMS::Client.instance.auth_setup(username, apikey)
    end

    def groups
      group_list = []
      MMS::Client.instance.get('/groups').each do |group|
        group_list.push MMS::Resource::Group.new group['id'], group
      end
      group_list
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
      findGroup(group_id).cluster(cluster_id).snapshot(snapshot_id).create_restorejob
    end

    def findGroup(id)
      MMS::Resource::Group.new id
    end
  end
end
