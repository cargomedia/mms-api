module MMS
  class Resource::Alert < Resource
    attr_accessor :name

    attr_accessor :type_name
    attr_accessor :event_type_name
    attr_accessor :status
    attr_accessor :acknowledged_until
    attr_accessor :created
    attr_accessor :updated
    attr_accessor :resolved
    attr_accessor :last_notified
    attr_accessor :current_value

    # @return [MMS::Resource::Group]
    def group
      MMS::Resource::Group.find(@client, @data['groupId'])
    end

    # @param [Time, Integer] time
    # @param [String] description
    # @return [TrueClass, FalseClass]
    def ack(time, description)
      data = {
        acknowledgedUntil: time.to_i,
        acknowledgementComment: description
      }
      alert = @client.post '/groups/' + group.id + '/alerts/' + @id, data
      !alert.nil?
    end

    def table_row
      [@status, group.name, @type_name, @event_type_name, @created, @updated, @resolved, @last_notified, JSON.dump(@current_value)]
    end

    def table_section
      rows = []
      rows << table_row
      rows << [{ value: "AlertId: #{@id}   GroupId: #{group.id}", colspan: 9, alignment: :left }]
      rows << :separator
      rows
    end

    def self.table_header
      ['Status', 'Group', 'Type', 'Event name', 'Created', 'Updated', 'Resolved', 'Last notified', 'Value']
    end

    # @param [MMS::Client] client
    # @param [String] group_id
    # @param [String] id
    # @return [Hash]
    def self._find(client, group_id, id)
      client.get('/groups/' + group_id + '/alerts/' + id)
    end

    private

    # @param [Hash] data
    def _from_hash(data)
      @type_name = data['typeName']
      @event_type_name = data['eventTypeName']
      @status = data['status']
      @acknowledged_until = data['acknowledgedUntil']
      @created = data['created']
      @updated = data['updated']
      @resolved = data['resolved']
      @last_notified = data['lastNotified']
      @current_value = data['currentValue']
      @name = @type_name
    end

    def _to_hash
      @data
    end
  end
end
