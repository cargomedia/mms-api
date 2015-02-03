module MMS

  class DeclarationError < StandardError
  end

  class RuntimeError < StandardError;

    def initialize(message, request, response)
      super(message)

      @request = request
      @response = response
    end

    attr_reader :request
    attr_reader :response

  end

  class ApiError < RuntimeError

    def initialize(message, request, response)
      super("API Response error! Code: #{response.code}, body: #{response.body}", request, response)
    end

  end

  class AuthError < RuntimeError

    def initialize(message, request, response)
      super("Authentication needed!", request, response)
    end

  end

  class ResourceError < StandardError

    def initialize(message, resource)
      super(message)

      @resource = resource
    end

    attr_reader :resource

  end

end
