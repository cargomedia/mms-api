module MMS

  class Resource::Metric < Resource

    attr_accessor :name
    attr_accessor :units
    attr_accessor :granularity
    attr_accessor :data_points

    def host
      MMS::Resource::Host.find(@client, @data['groupId'], @data['hostId'])
    end

    # @param [Hash] options
    # @returns [Array<Hash>]
    def data_points(options = {})
      series = []
      metric_data = get_metric_data(options)
      if !metric_data.is_a?(Array)
        series << metric_data
      else
        metric_data.each do |m|
          d_name = (m['deviceName'] || '') + (m['databaseName'] || '')
          series << get_metric_data(options, d_name)
        end
      end
      series
    end

    # @param [MMS::Client] client
    # @param [String] group_id
    # @param [String] host_id
    # @param [String] metric_name
    # @returns [Hash]
    def self._find(client, group_id, host_id, metric_name)
      client.get('/groups/' + group_id + '/hosts/' + host_id + '/metrics/' + metric_name)
    end

    private

    # @param [Hash] options
    # @param [String] name
    # @returns [Hash]
    def get_metric_data(options = {}, d_name = '')
      params = options.map { |k, v| "#{k}=#{v}" }.join('&')
      ret = client.get("/groups/#{@data['groupId']}/hosts/#{@data['hostId']}/metrics/#{@data['metricName']}/#{d_name}?#{params}")
      ret.delete("links")
      ret
    end

    def _from_hash(data)
      @name = data['metricName']
      @units = data['units']
      @granularity = data['granularity']
      @data_points = data['dataPoints']
      data.delete('links')
    end

    def _to_hash
      @data
    end
  end
end
