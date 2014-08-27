module MMS

  class Resource::Snapshot < Resource

    attr_accessor :name
    attr_accessor :cluster

    attr_accessor :complete
    attr_accessor :created_date
    attr_accessor :created_increment
    attr_accessor :expires
    attr_accessor :parts

    def initialize(id, cluster_id, group_id, data = nil)
      @cluster = MMS::Resource::Cluster.new cluster_id, group_id

      super id, data
    end

    def _load(id)
      MMS::Client.instance.get('/groups/' + @cluster.group.id + '/clusters/' + @cluster.id + '/snapshots/' + id.to_s)
    end

    def create_restorejob
      data = {:snapshotId => @id}
      jobs = MMS::Client.instance.post '/groups/' + @cluster.group.id + '/clusters/' + @cluster.id + '/restoreJobs', data

      if jobs.nil?
        raise "Cannot create job from snapshot `#{self.id}`"
      end

      job_list = []
      # work around due to bug in MMS API; cannot read restoreJob using provided info.
      restore_jobs = @cluster.restorejobs

      jobs.each do |job|
        _list = restore_jobs.select {|restorejob| restorejob.id == job['id'] }
        _list.each do |restorejob|
          begin
            job_list.push MMS::Resource::RestoreJob.new(restorejob.id, restorejob.cluster.id, restorejob.cluster.group.id)
          rescue => e
            puts "load error #{e.message}"
          end
        end
      end
      job_list
    end

    def _from_hash(data)
      @complete = data['complete']
      @created_date = data['created']['date']
      @created_increment = data['created']['increment']
      @expires = data['expires']
      @parts = data['parts']
    end
  end
end
