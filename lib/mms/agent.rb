module MMS

  class Agent

    attr_accessor :client

    # @param [MMS::Client] client
    def initialize(client)
      @client = client
    end

    # @param [String] apiurl
    def set_apiurl(apiurl)
      @client.url = apiurl
    end

    # @return [Array<MMS::Resource::Group>]
    def groups
      group_list = []
      client.get('/groups').each do |group|
        g = MMS::Resource::Group.new
        g.set_client(client)
        g.set_data(group)

        group_list.push g
      end
      group_list
    end

    # @return [Array<MMS::Resource::Host>]
    def hosts
      host_list = []
      groups.each do |group|
        host_list.concat group.hosts
      end
      host_list
    end

    # @return [Array<MMS::Resource::Cluster>]
    def clusters
      cluster_list = []
      groups.each do |group|
        cluster_list.concat group.clusters
      end
      cluster_list
    end

    # @return [Array<MMS::Resource::Snapshot>]
    def snapshots
      snapshot_list = []
      clusters.each do |cluster|
        snapshot_list.concat cluster.snapshots
      end
      snapshot_list.sort_by { |snapshot| snapshot.created_date }.reverse
    end

    # @return [Array<MMS::Resource::Alert>]
    def alerts
      alert_list = []
      groups.each do |group|
        alert_list.concat group.alerts
      end
      alert_list.sort_by { |alert| alert.created }.reverse
    end

    # @return [Array<MMS::Resource::RestoreJob>]
    def restorejobs
      restorejob_list = []
      clusters.each do |cluster|
        restorejob_list.concat cluster.restorejobs
      end
      restorejob_list.sort_by { |job| job.created }.reverse
    end

    # @param [String] type_value
    # @param [Object] group_id
    # @param [Object] cluster_id
    # @return [Array<MMS::Resource::RestoreJob>]
    def restorejob_create(type_value, group_id, cluster_id)
      if type_value.length == 24
        find_group(group_id).cluster(cluster_id).snapshot(type_value).create_restorejob
      elsif datetime = (type_value == 'now' ? DateTime.now : DateTime.parse(type_value))
        raise('Invalid datetime. Correct `YYYY-MM-RRTH:m:s`') if datetime.nil?
        datetime_string = [[datetime.year, datetime.day, datetime.month].join('-'), 'T', [datetime.hour, datetime.minute, datetime.second].join(':'), 'Z'].join
        find_group(group_id).cluster(cluster_id).create_restorejob(datetime_string)
      end
    end

    # @param [String] alert_id
    # @param [String, Integer] timestamp
    # @param [String] group_id
    # @return [Array<MMS::Resource::RestoreJob>]
    def alert_ack(alert_id, timestamp, group_id)
      timestamp = DateTime.now if timestamp == 'now'
      timestamp = DateTime.new(4000, 1, 1, 1, 1, 1, 1, 1) if timestamp == 'forever'

      group = find_group(group_id)

      if alert_id == 'all'
        group.alerts.each do |alert|
          alert.ack(timestamp, 'Triggered by CLI for all alerts.')
        end
      else
        group.alert(alert_id).ack(timestamp, 'Triggered by CLI.')
      end
    end

    # @param [String] id
    # @return [MMS::Resource::Group]
    def find_group(id)
      MMS::Resource::Group.find(@client, id)
    end

  end
end
