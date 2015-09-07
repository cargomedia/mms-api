module MMS

  class Resource::Metric < Resource

    attr_accessor :name

    def group
      MMS::Resource::Group.find(@client, @data['groupId'])
    end

    def host
      MMS::Resource::Host.find(@client, @data['hostId'])
    end

    def data_points(options = {})
      metric_data = get_metric_data(options)
      if !metric_data.is_a?(Array)
        metric_data
      else
        series = []
        metric_data.each do |m|
          d_name = (m['deviceName'] || "" ) + ( m['databaseName'] || "" )
          series << get_metric_data(options, d_name)
        end
        series
      end
    end

    private

    def get_metric_data(options = {}, d_name = "")
      params = options.map { |k,v| "#{k}=#{v}" }.join('&')
      client.get("/groups/#{@data['groupId']}/hosts/#{@data['hostId']}/metrics/#{@data['metricName']}/#{d_name}?#{params}")
    end

    def _from_hash(data)
      @name = data['metricName']
    end

    def _to_hash
      @data
    end
  end
end
