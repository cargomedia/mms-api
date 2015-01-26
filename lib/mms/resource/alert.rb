module MMS

  class Resource::Alert < Resource

    @client = nil

    attr_accessor :name
    attr_accessor :group

    attr_accessor :type_name
    attr_accessor :event_type_name
    attr_accessor :status
    attr_accessor :acknowledged_until
    attr_accessor :created
    attr_accessor :updated
    attr_accessor :resolved
    attr_accessor :last_notified
    attr_accessor :current_value

    def initialize(client, data)
      id = data['id']
      group_id = data['groupId']

      raise('`Id` for alert resource must be defined') if id.nil?
      raise('`groupId` for alert resource must be defined') if group_id.nil?

      @client = client

      @group = MMS::Resource::Group.new(client, {'id' => group_id})

      super id, data
    end

    def ack(time, description)
      data = {
          :acknowledgedUntil => time,
          :acknowledgementComment => description
      }
      alert = @client.post '/groups/' + @group.id + '/alerts/' + @id, data
      !alert.nil?
    end

    def table_row
      [@status, @group.name, @type_name, @event_type_name, @created, @updated, @resolved, @last_notified, JSON.dump(@current_value)]
    end

    def table_section
      rows = []
      rows << table_row
      rows << [{:value => "AlertId: #{@id}   GroupId: #{@group.id}", :colspan => 9, :alignment => :left}]
      rows << :separator
      rows
    end

    def self.table_header
      ['Status', 'Group', 'Type', 'Event name', 'Created', 'Updated', 'Resolved', 'Last notified', 'Value']
    end

    private

    def _load(id)
      @client.get '/groups/' + @group.id + '/alerts/' + id.to_s
    end

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
  end
end
