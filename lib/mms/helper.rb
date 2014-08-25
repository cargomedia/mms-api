require "net/http"
require "uri"
require 'net/http/digest_auth'
require 'json'

module MMS

  class Helper

    def self.get(path, username, password)

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

      if response_json['results'].nil?
        fail("Error during API request!")
      end

      response_json['results']
    end
  end
end
