require "uri"
require 'json'
require "net/http"
require 'net/http/digest_auth'

module MMS

  class Client

    @config = nil

    def initialize(config = nil)
      if config.nil?
        @config = MMS::Config.new
      elsif @config = config
      end
    end

    def set_options(options = {})
      options.each do |h, k|
        @config.public_send("#{h}=", k)
      end
    end

    def auth_setup(username = nil, apikey = nil)
      @config.username = username
      @config.apikey = apikey
    end

    def site
      [@config.api_protocol, '://', @config.api_host, ':', @config.api_port, @config.api_path, '/', @config.api_version].join.to_s
    end

    def get(path)
      _get(site + path, @config.username, @config.apikey)
    end

    def self.post(path, data)
      _post(site + path, data, @config.username, @config.apikey)
    end

    private

    def _get(path, username, password)

      digest_auth = Net::HTTP::DigestAuth.new
      digest_auth.next_nonce

      uri = URI.parse path
      uri.user= CGI.escape(username)
      uri.password= CGI.escape(password)

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true

      req = Net::HTTP::Get.new uri.request_uri
      res = http.request req

      auth = digest_auth.auth_header uri, res['WWW-Authenticate'], 'GET'
      req = Net::HTTP::Get.new uri.request_uri
      req.add_field 'Authorization', auth

      response = http.request(req)
      response_json = JSON.parse(response.body)

      unless response_json['error'].nil?
        raise(JSON.dump(response_json))
      end

      (response_json.nil? or response_json['results'].nil?) ? response_json : response_json['results']
    end

    def _post(path, data, username, password)
      digest_auth = Net::HTTP::DigestAuth.new
      digest_auth.next_nonce

      uri = URI.parse path
      uri.user= CGI.escape(username)
      uri.password= CGI.escape(password)

      http = Net::HTTP.new uri.host, uri.port
      http.use_ssl = true

      req = Net::HTTP::Post.new uri.request_uri, {'Content-Type' => 'application/json'}
      res = http.request req

      auth = digest_auth.auth_header uri, res['WWW-Authenticate'], 'POST'
      req = Net::HTTP::Post.new uri.request_uri, {'Content-Type' => 'application/json'}
      req.add_field 'Authorization', auth
      req.body = data.to_json

      response = http.request req
      response_json = JSON.parse response.body

      unless response_json['error'].nil?
        raise(JSON.dump(response_json))
      end

      (response_json.nil? or response_json['results'].nil?) ? response_json : response_json['results']
    end

  end
end
