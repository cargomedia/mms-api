module MMS

  class Resource::Metric < Resource

    attr_accessor :name

    def group
      MMS::Resource::Group.find(@client, @data['groupId'])
    end

    def host
      MMS::Resource::Host.find(@client, @data['hostId'])
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
          d_name = (m['deviceName'] || "" ) + ( m['databaseName'] || "" )
          series << get_metric_data(options, d_name)
        end
      end
      series
    end

    private

    # @param [Hash] options
    # @param [String] name
    # @returns [Hash]
    def get_metric_data(options = {}, d_name = "")
      params = options.map { |k,v| "#{k}=#{v}" }.join('&')
      ret = client.get("/groups/#{@data['groupId']}/hosts/#{@data['hostId']}/metrics/#{@data['metricName']}/#{d_name}?#{params}")
      ret.delete("links")
      ret
    end

    def _from_hash(data)
      @name = data['metricName']
      data.delete('links')
    end

    def _to_hash
      @data
    end
  end
end
