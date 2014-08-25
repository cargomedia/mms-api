module MMS

  class Agent

    attr_accessor :api_protocol
    attr_accessor :api_host
    attr_accessor :api_port
    attr_accessor :api_path
    attr_accessor :api_version

    attr_accessor :username
    attr_accessor :apikey

    attr_accessor :client

    def initialize(username, apikey, client = nil)
      @api_protocol = 'https'
      @api_host = 'mms.mongodb.com'
      @api_port = '443'
      @api_path = '/api/public'
      @api_version = 'v1.0'

      @username = username
      @apikey = apikey

      @client = client.nil? ? MMS::Client.new(get_url, @username, @apikey) : client
    end

    def get_url
      [@api_protocol, '://', @api_host, ':', @api_port, @api_path, '/',  @api_version].join.to_s
    end

    def groups
      MMS::Resource::Group.new(@client).load_list
    end

    def clusters(group_list = [])
      if group_list.empty?
        groups.each do |group|
          group_list.push group.id
        end
      end

      results = []
      group_list.each do |group|
        output = MMS::Helper.get get_url + '/groups/' + group + '/clusters', @username, @apikey
        results = results + output
      end

      results
    end

    def snapshots(cluster_list = [])
      if cluster_list.empty?
        clusters.each do |cluster|
          cluster_list.push({
            :id => cluster['id'],
            :group_id => cluster['groupId']
          })
        end
      end

      results = []
      cluster_list.each do |cluster|
        output = MMS::Helper.get get_url + '/groups/' + cluster[:group_id] + '/clusters/' + cluster[:id] + '/snapshots' , @username, @apikey
        results = results + output
      end

      results
    end

    def restorejobs(cluster_list = [])
      if cluster_list.empty?
        clusters.each do |cluster|
          cluster_list.push({
            :id => cluster['id'],
            :group_id => cluster['groupId']
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

    def restorejobs_create(snapshot = nil, point_in_time = nil)

    end

  end
end
