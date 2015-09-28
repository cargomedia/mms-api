module MMS

  class Resource::Cluster < Resource

    attr_accessor :name
    attr_accessor :shard_name
    attr_accessor :replicaset_name
    attr_accessor :type_name
    attr_accessor :last_heartbeat

    attr_accessor :snapshots
    attr_accessor :restorejobs

    def initialize
      @snapshots = []
      @restorejobs = []
    end

    def group
      MMS::Resource::Group.find(@client, @data['groupId'])
    end

    def snapshot(id)
      MMS::Resource::Snapshot.find(@client, group.id, @id, nil, id)
    end

    def snapshots(page = 1, limit = 1000)
      if @snapshots.empty?
        @client.get('/groups/' + group.id + '/clusters/' + @id + '/snapshots?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |snapshot|
          s = MMS::Resource::Snapshot.new
          s.set_client(@client)
          s.set_data(snapshot)

          @snapshots.push s
        end
      end
      @snapshots
    end

    def snapshot_schedule
      MMS::Resource::SnapshotSchedule.find(@client, group.id, @id)
    end

    def restorejobs(page = 1, limit = 1000)
      if @restorejobs.empty?
        @client.get('/groups/' + group.id + '/clusters/' + @id + '/restoreJobs?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |job|

          job['clusterId'] = @id
          job['groupId'] = group.id

          j = MMS::Resource::RestoreJob.new
          j.set_client(@client)
          j.set_data(job)

          @restorejobs.push j
        end
      end
      @restorejobs
    end

    # @param [String] point_in_time
    # @return [Array<MMS::Resource::RestoreJob>]
    def create_restorejob(point_in_time = nil)
      data = {
        'timestamp' => {
          'date' => point_in_time,
          'increment' => 0
        }
      }
      job_data_list = @client.post('/groups/' + group.id + '/clusters/' + @id + '/restoreJobs', data)

      if job_data_list.nil?
        raise MMS::ResourceError.new("Cannot create job from snapshot `#{self.id}`", self)
      end

      job_data_list.map do |job_data|
        j = MMS::Resource::RestoreJob.new
        j.set_client(@client)
        j.set_data(job_data)
        j
      end
    end

    def table_row
      [group.name, @name, @shard_name, @replicaset_name, @type_name, @last_heartbeat, @id]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Group', 'Cluster', 'Shard name', 'Replica name', 'Type', 'Last heartbeat', 'Cluster Id']
    end

    def self._find(client, group_id, id)
      client.get('/groups/' + group_id + '/clusters/' + id)
    end

    private

    def _from_hash(data)
      @name = data['clusterName']
      @shard_name = data['shardName']
      @replicaset_name = data['replicaSetName']
      @type_name = data['typeName']
      @last_heartbeat = data['lastHeartbeat']
    end

    def _to_hash
      @data
    end

  end
end
