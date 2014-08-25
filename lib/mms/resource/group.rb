require 'json'

module MMS

  class Resource::Group < Resource

    attr_accessor :activeAgentCount
    attr_accessor :replicaSetCount
    attr_accessor :shardCount
    attr_accessor :lastActiveAgent

    def initialize(client, data = nil)
      from_hash(data)
      super client, data
    end

    def load_list
      group_list = []
      @client.get('/groups').each do |group|
        group_list.push MMS::Resource::Group.new(@client, group)
      end

      group_list
    end

    def load_one
    end

    def activeAgentCount
      @activeAgentCount
    end

    def replicaSetCount
      @replicaSetCount
    end

    def shardCount
      @shardCount
    end

    def lastActiveAgent
      @lastActiveAgent
    end

    def from_hash(data)
      unless data.nil?
        @activeAgentCount = data['activeAgentCount']
        @replicaSetCount = data['replicaSetCount']
        @shardCount = data['shardCount']
        @lastActiveAgent = data['lastActiveAgent']
      end

      super data
    end
  end
end
