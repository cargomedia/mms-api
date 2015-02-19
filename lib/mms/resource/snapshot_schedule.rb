module MMS

  class Resource::SnapshotSchedule < Resource

    attr_accessor :name

    attr_accessor :snapshot_interval_hours
    attr_accessor :snapshot_retention_days
    attr_accessor :cluster_checkpoint_interval_min
    attr_accessor :daily_snapshot_retention_days
    attr_accessor :weekly_snapshot_retention_weeks
    attr_accessor :monthly_snapshot_retention_months

    # @return [MMS::Resource::Cluster]
    def cluster
      MMS::Resource::Cluster.find(@client, @data['groupId'], @data['clusterId'])
    end

    def table_row
      [
          cluster.group.name,
          cluster.name,
          @snapshot_interval_hours,
          @snapshot_retention_days,
          @cluster_checkpoint_interval_min,
          @daily_snapshot_retention_days,
          @weekly_snapshot_retention_weeks,
          @monthly_snapshot_retention_months,
      ]
    end

    def table_section
      [table_row]
    end

    def self.table_header
      ['Group', 'Cluster', 'IntervalHours', 'RetentionDays', 'CheckpointIntervalMin', 'RetentionDays', 'RetentionWeeks', 'RetentionMonths']
    end

    def self._find(client, group_id, cluster_id)
      client.get('/groups/' + group_id + '/backupConfigs/' + cluster_id + '/snapshotSchedule')
    end

    private

    def _from_hash(data)
      @snapshot_interval_hours = data['snapshotIntervalHours']
      @snapshot_retention_days = data['snapshotRetentionDays']
      @cluster_checkpoint_interval_min = data['clusterCheckpointIntervalMin']
      @daily_snapshot_retention_days = data['dailySnapshotRetentionDays']
      @weekly_snapshot_retention_weeks = data['weeklySnapshotRetentionWeeks']
      @monthly_snapshot_retention_months = data['monthlySnapshotRetentionMonths']
    end

    def _to_hash
      @data
    end

  end
end
