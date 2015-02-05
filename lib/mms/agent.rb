module MMS

  class Agent

    attr_accessor :client

    def initialize(client)
      @client = client
    end

    def set_apiurl(apiurl)
      @client.url = apiurl
    end

    def groups
      MMS::Resource::Group.findGroups(@client)
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
      cluster_list
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

    def restorejob_create(type_value, group_id, cluster_id)
      if type_value.length == 24
        findGroup(group_id).cluster(cluster_id).snapshot(type_value).create_restorejob
      elsif datetime = (type_value == 'now' ? DateTime.now : DateTime.parse(type_value))
        raise('Invalid datetime. Correct `YYYY-MM-RRTH:m:s`') if datetime.nil?
        datetime_string = [[datetime.year, datetime.day, datetime.month].join('-'), 'T', [datetime.hour, datetime.minute, datetime.second].join(':'), 'Z'].join
        findGroup(group_id).cluster(cluster_id).create_restorejob(datetime_string)
      end
    end

    def alert_ack(alert_id, timestamp, group_id)
      timestamp = DateTime.now if timestamp == 'now'
      timestamp = DateTime.new(4000, 1, 1, 1, 1, 1, 1, 1) if timestamp == 'forever'

      group = findGroup(group_id)

      if alert_id == 'all'
        group.alerts.each do |alert|
          alert.ack(timestamp, 'Triggered by CLI for all alerts.')
        end
      elsif group.alert(alert_id).ack(timestamp, 'Triggered by CLI.')
      end
    end

    def findGroup(id)
      MMS::Resource::Group.new(@client, {'id' => id})
    end

  end
end
