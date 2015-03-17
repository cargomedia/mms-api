module MMS

  class Client

    attr_accessor :username
    attr_accessor :apikey
    attr_accessor :url

    # @param [String] username
    # @param [String] apikey
    # @param [String] url
    def initialize(username = nil, apikey = nil, url = nil)
      @username = username
      @apikey = apikey
      @url = url.nil? ? 'https://mms.mongodb.com:443/api/public/v1.0' : url
    end

    # @param [String] path
    # @return [Hash]
    def get(path)
      method ={
        :name => "GET",
        :http_method => Net::HTTP::Get
      }
      _request(@url + path, @username, @apikey, nil, method)
    end

    # @param [String] path
    # @param [Hash] data
    # @return [Hash]
    def post(path, data)
      method = {
        :name => "POST",
        :http_method => Net::HTTP::Post
      }
      _request(@url + path, @username, @apikey, data, method)
    end

    private

    # @param [String] path
    # @param [String] username
    # @param [String] password
    # @param [Hash] data
    # @param [Hash] method
    # @return [Hash]
    def _request(path, username, password, data = nil, method = {})

      digest_auth = Net::HTTP::DigestAuth.new
      digest_auth.next_nonce

      uri = URI.parse path
      uri.user= CGI.escape(username)
      uri.password= CGI.escape(password)

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = (uri.scheme == 'https')

      req = method[:http_method].new uri.request_uri, {'Content-Type' => 'application/json'}
      res = http.request req
      auth = digest_auth.auth_header uri, res['WWW-Authenticate'], method[:name]
      req = method[:http_method].new uri.request_uri, {'Content-Type' => 'application/json'}
      req.add_field 'Authorization', auth
      req.body = data.to_json

      response = http.request req
      response_json = JSON.parse response.body

      unless response.code == 200 or response_json['error'].nil?
        msg = "http 'get' error for url `#{url}`"
        msg = response_json['detail'] unless response_json['detail'].nil?

        raise MMS::AuthError.new(msg, req, response) if response.code == '401'
        raise MMS::ApiError.new(msg, req, response)
      end

      (response_json.nil? or response_json['results'].nil?) ? response_json : response_json['results']
    end

  end
end
