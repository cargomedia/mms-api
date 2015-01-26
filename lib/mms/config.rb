require 'singleton'

module MMS

  class Config

    default = {
        username: proc {
          nil
        },
        apikey: proc {
          nil
        },
        apiurl: proc {
          [api_protocol, '://', api_host, ':', api_port, api_path, '/', api_version].join.to_s
        },
        limit: proc {
          5
        },
        api_protocol: proc {
          'https'
        },
        api_host: proc {
          'mms.mongodb.com'
        },
        api_port: proc {
          '443'
        },
        api_path: proc {
          '/api/public'
        },
        api_version: proc {
          'v1.0'
        },
        action: proc {
          nil
        },
        group_id: proc {
          nil
        },
        cluster_id: proc {
          nil
        }
    }

    default.each do |key, value|
      define_method(key) do
        if default[key].equal?(value)
          default[key] = instance_eval(&value)
        end
        default[key]
      end
      define_method("#{key}=") do |value|
        default[key] = value
      end
    end

  end
end
