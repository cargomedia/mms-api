module MMS

  class Agent

    @default_group = nil
    @default_cluster = nil

    def initialize(username = nil, apikey = nil, group_id = nil, cluster_id = nil)
      MMS::Client.instance.auth_setup(username, apikey)
      @default_group = group_id || MMS::Config.group_id
      @default_cluster = cluster_id || MMS::Config.cluster_id
    end

    def set_apiurl(apiurl)
      begin
        url_info = URI(apiurl)
      rescue URI::InvalidURIError
        puts "Unable to parse given apiurl: #{apiurl}"
        exit
      end

      # Split out version from URL path
      path_parts = url_info.path.split '/'
      api_version = path_parts.pop
      url_info.path = path_parts.join '/'

      # Update client singleton
      MMS::Client.instance.api_protocol = url_info.scheme
      MMS::Client.instance.api_host = url_info.host
      MMS::Client.instance.api_port = url_info.port
      MMS::Client.instance.api_path = url_info.path
      MMS::Client.instance.api_version = api_version
    end

    def groups
      group_list = []
      MMS::Client.instance.get('/groups').each do |group|
        group_list.push MMS::Resource::Group.new group['id'], group
      end
      group_list.select { |group| group.id == @default_group or @default_group.nil? }
    end

    def hosts
      host_list = []
      groups.each do |group|
        host_list.concat group.hosts
      end
      host_list
    end

    def clusters
      cluster_list = []
      groups.each do |group|
        cluster_list.concat group.clusters
      end
      cluster_list.select { |cluster| cluster.id == @default_cluster or @default_cluster.nil? }
    end

    def snapshots
      snapshot_list = []
      clusters.each do |cluster|
        snapshot_list.concat cluster.snapshots
      end
      snapshot_list.sort_by { |snapshot| snapshot.created_date }.reverse
    end

    def restorejobs
      restorejob_list = []
      clusters.each do |cluster|
        restorejob_list.concat cluster.restorejobs
      end
      restorejob_list.sort_by { |job| job.created }.reverse
    end

    def restorejobs_create(group_id, cluster_id, snapshot_id)
      findGroup(group_id).cluster(cluster_id).snapshot(snapshot_id).create_restorejob
    end

    def findGroup(id)
      MMS::Resource::Group.new id
    end
  end
end
