require 'date'

module MMS

  class Resource::BackupConfig < Resource

    attr_accessor :cluster_id
    attr_accessor :excluded_namespaces
    attr_accessor :group_id
    attr_accessor :links
    attr_accessor :status_name

    # @return [TrueClass, FalseClass]
    def is_active
      'STARTED'.eql? @status_name
    end

    # @return [String, NilClass]
    def cluster_name
      cluster.name if is_cluster
    end

    # @return [MMS::Resource::Cluster]
    def cluster
      MMS::Resource::Cluster.find(@client, @data['groupId'], @data['clusterId'])
    end

    def table_row
      [cluster.group.name, cluster.name, @id, @excluded_namespaces, @group_id, @links, @status_name, @cluster_id]
    end

    def table_section
      rows = []
      rows << table_row
      rows << :separator
      rows
    end

    def self.table_header
      ['Group', 'Cluster', 'BackupId', 'Excluded namespaces', 'Group Id', 'Links', 'Status name', 'Cluster id']
    end

    private

    def _from_hash(data)
      puts '--------------------------------------------------------------------'
      puts data.inspect
      @cluster_id = data['clusterId']
      @excluded_namespaces = data['excludedNamespaces']
      @group_id = data['groupId']
      @links = data['links']
      @status_name = data['statusName']
    end

    def _to_hash
      @data
    end

  end
end
