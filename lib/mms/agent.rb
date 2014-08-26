module MMS

  class Agent

    attr_accessor :api_protocol
    attr_accessor :api_host
    attr_accessor :api_port
    attr_accessor :api_path
    attr_accessor :api_version

    attr_accessor :username
    attr_accessor :apikey

    def initialize(username, apikey)
      @api_protocol = 'https'
      @api_host = 'mms.mongodb.com'
      @api_port = '443'
      @api_path = '/api/public'
      @api_version = 'v1.0'

      @username = username
      @apikey = apikey

      MMS::Client.instance.setup(get_url, @username, @apikey)
    end

    def get_url
      [@api_protocol, '://', @api_host, ':', @api_port, @api_path, '/',  @api_version].join.to_s
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
