module MMS

  class Resource::Metric < Resource

    attr_accessor :name
    attr_accessor :units

    def group
      MMS::Resource::Group.find(@client, @data['groupId'])
    end

    def host
      MMS::Resource::Host.find(@client, @data['hostId'])
    end

    def data_points(options = {})
      metric_data = client.get("/groups/#{group.id}/hosts/#{host.id}/metrics/#{@name}?#{options.map{ |k,v| "#{k}=#{v}" }.join('&') }")
      if !metric_data.is_a?(Array)
        metric_data['dataPoints']
      else
        series = []
        metric_data.each do |m|
          m_data = {}
          m_data['name'] = m['deviceName'] if m['deviceName'] != nil
          m_data['name'] = m['databaseName'] if m['databaseName'] != nil
          m.has_key?('deviceName') ? (m_data['type'] = 'device') : (m_data['type'] = 'database')
          m_data['data_points'] = client.get("/groups/#{group.id}/hosts/#{host.id}/metrics/#{@name}/#{m_data['name']}?#{options.map{ |k,v| "#{k}=#{v}"  }.join('&') }")['dataPoints']
          series << data
        end
        series
      end
    end

    private

    def _from_hash(data)
      @name = data['metricName']
      @units = data['units']
    end

    def _to_hash
      @data
    end
  end
end
