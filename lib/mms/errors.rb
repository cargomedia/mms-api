module MMS
  class RuntimeError < StandardError
    # @param [String] message
    # @param [Net::HTTPRequest] request
    # @param [Net::HTTPResponse] response
    def initialize(message, request, response)
      super(message)

      @request = request
      @response = response
    end

    attr_reader :request
    attr_reader :response
  end

  class ResourceError < StandardError
    # @param [String] message
    # @param [MMS::Resource] resource
    def initialize(message, resource)
      super(message)

      @resource = resource
    end

    attr_reader :resource
  end

  class ApiError < RuntimeError
    def initialize(_message, request, response)
      super("API Response error! Code: #{response.code}, body: #{response.body}", request, response)
    end
  end

  class AuthError < RuntimeError; end

  class ConfigError < StandardError; end
end
