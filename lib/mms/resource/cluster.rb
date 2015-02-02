module MMS

  class Resource::Cluster < Resource

    @client = nil

    attr_accessor :name
    attr_accessor :group
    attr_accessor :shard_name
    attr_accessor :replicaset_name
    attr_accessor :type_name
    attr_accessor :last_heartbeat

    attr_accessor :snapshots
    attr_accessor :restorejobs

    def initialize(client, data)
      id = data['id']
      group_id = data['groupId']

      raise('`Id` for cluster resource must be defined') if id.nil?
      raise('`groupId` for cluster resource must be defined') if group_id.nil?

      @snapshots = []
      @restorejobs = []

      @client = client

      @group = MMS::Resource::Group.new(client, {'id' => group_id})

      super id, data
    end

    def snapshot(id)
      MMS::Resource::Snapshot.new(@client, {'id' => id, 'clusterId' => @id, 'groupId' => @group.id})
    end

    def snapshots(page = 1, limit = 10)
      if @snapshots.empty?
        @client.get('/groups/' + @group.id + '/clusters/' + @id + '/snapshots?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |snapshot|
          @snapshots.push MMS::Resource::Snapshot.new(@client, snapshot)
        end
      end
      @snapshots
    end

    def restorejobs(page = 1, limit = 10)
      if @restorejobs.empty?
        @client.get('/groups/' + @group.id + '/clusters/' + @id + '/restoreJobs?pageNum=' + page.to_s + '&itemsPerPage=' + limit.to_s).each do |job|

          if job['snapshotId'].nil? and job['clusterId'].nil?
            raise("RestoreJob `#{job['id']}` with status `#{job['statusName']}` has no `clusterId` and no `snapshotId`.")
          elsif job['clusterId'].nil?
            snapshot = @group.findSnapshot(job['snapshotId'])
            job['clusterId'] = snapshot.cluster.id unless snapshot.nil?
          end

          @restorejobs.push MMS::Resource::RestoreJob.new(@client, job)
        end
      end
      @restorejobs
    end

    def create_restorejob(point_in_time = nil)
      data = {
          'timestamp' => {
              'date' => point_in_time,
              'increment' => 0
          }
      }
      jobs = @client.post('/groups/' + @group.id + '/clusters/' + @id + '/restoreJobs', data)

      if jobs.nil?
        raise "Cannot create job from snapshot `#{self.id}`"
      end

      job_list = []
      # work around due to bug in MMS API; cannot read restoreJob using provided info.
      # The config-server RestoreJob and Snapshot has no own ClusterId to be accessed.
      tries = 5
      while tries > 0
        begin
          restore_jobs = restorejobs
          tries = 0
        rescue Exception => e
          tries-=1;
          raise(e.message) if tries < 1

          puts e.message
          puts 'Sleeping for 5 seconds. Trying again...'
          sleep(5)
        end
      end

      jobs.each do |job|
        _list = restore_jobs.select { |restorejob| restorejob.id == job['id'] }
        _list.each do |restorejob|
          job_list.push restorejob
        end
      end
      job_list
    end

    def table_row
      [@group.name, @name, @shard_name, @replicaset_name, @type_name, @last_heartbeat, @id]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Group', 'Cluster', 'Shard name', 'Replica name', 'Type', 'Last heartbeat', 'Cluster Id']
    end

    private

    def _load(id)
      @client.get('/groups/' + @group.id + '/clusters/' + id.to_s)
    end

    def _from_hash(data)
      @name = data['clusterName']
      @shard_name = data['shardName']
      @replicaset_name = data['replicaSetName']
      @type_name = data['typeName']
      @last_heartbeat = data['lastHeartbeat']
    end
  end
end
