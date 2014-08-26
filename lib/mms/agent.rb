module MMS

  class Agent

    attr_accessor :username
    attr_accessor :apikey

    def initialize(username, apikey)
      @username = username
      @apikey = apikey

      MMS::Client.instance.auth_setup(@username, @apikey)
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

    def restorejobs(cluster_list = [])
      if cluster_list.empty?
        clusters.each do |cluster|
          cluster_list.push({
            :id => cluster.id,
            :group_id => cluster.group.id
          })
        end
      end

      results = []
      cluster_list.each do |cluster|
        output = MMS::Helper.get get_url + '/groups/' + cluster[:group_id] + '/clusters/' + cluster[:id] + '/restoreJobs' , @username, @apikey
        results = results + output
      end

      results
    end

  end
end
