require 'singleton'
require "net/http"
require "uri"
require 'net/http/digest_auth'
require 'json'

module MMS

  class Client

    def initialize(options = {})
      @options = Hash.new

      set_options(options)
    end

    def set_options(options = {})
      @options = {
          :username => nil || @options[:username],
          :apikey => nil || @options[:apikey],
          :api_protocol => nil || @options[:api_protocol],
          :api_host => nil || @options[:api_host],
          :api_port => nil || @options[:api_port],
          :api_path => nil || @options[:api_path],
          :api_version => nil || @options[:api_version],
      }.merge(options)
    end

    def self.auth_setup(username = nil, apikey = nil)
      @options[:username]= username
      @options[:apikey] = apikey
    end

    def site
      [@options[:api_protocol], '://', @options[:api_host], ':', @options[:api_port], @options[:api_path], '/', @options[:api_version]].join.to_s
    end

    def get(path)
      _get site + path, @options[:username], @options[:apikey]
    end

    def self.post(path, data)
      _post site + path, data, @options[:username], @options[:apikey]
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
