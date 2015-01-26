module MMS

  class Agent

    @client = nil

    def initialize(config = nil, client = nil)
      if client.nil?
        @client = MMS::Client.new(config)
      elsif @client = client
      end
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

      # Update client
      @client.set_options(
          {
              :api_protocol => url_info.scheme,
              :api_host => url_info.host,
              :api_port => url_info.port,
              :api_path => url_info.path,
              :api_version => api_version,
          }
      )
    end

    def groups
      group_list = MMS::Resource::Group.findGroups(@client)
      group_list.select { |group| group.id == @config.group_id or @config.group_id.nil? }
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
      cluster_list.select { |cluster| cluster.id == @config.cluster_id or @config.cluster_id.nil? }
    end

    def snapshots
      snapshot_list = []
      clusters.each do |cluster|
        snapshot_list.concat cluster.snapshots
      end
      snapshot_list.sort_by { |snapshot| snapshot.created_date }.reverse
    end

    def alerts
      alert_list = []
      groups.each do |group|
        alert_list.concat group.alerts
      end
      alert_list.sort_by { |alert| alert.created }.reverse
    end

    def restorejobs
      restorejob_list = []
      clusters.each do |cluster|
        restorejob_list.concat cluster.restorejobs
      end
      restorejob_list.sort_by { |job| job.created }.reverse
    end

    def restorejob_create(type)
      if type.length == 24
        findGroup(@config.group_id).cluster(@config.cluster_id).snapshot(type_value).create_restorejob
      elsif datetime = (type == 'now' ? DateTime.now : DateTime.parse(type_value))
        raise('Invalid datetime. Correct `YYYY-MM-RRTH:m:s`') if datetime.nil?
        datetime_string = [[datetime.year, datetime.day, datetime.month].join('-'), 'T', [datetime.hour, datetime.minute, datetime.second].join(':'), 'Z'].join
        findGroup(@config.group_id).cluster(@config.cluster_id).create_restorejob(datetime_string)
      end
    end

    def alert_ack(alert_id, time)
      time = DateTime.now if time == 'now'
      time = DateTime.new(4000, 1, 1, 1, 1, 1, 1, 1) if time == 'forever'

      group = findGroup(@config.group_id)

      if alert_id == 'all'
        group.alerts.each do |alert|
          alert.ack(time, 'Triggered by CLI for all alerts.')
        end
      elsif group.alert(alert_id).ack(time, 'Triggered by CLI.')
      end
    end

    def findGroup(id)
      MMS::Resource::Group.new(@client, {'id' => id})
    end

  end
end
