require 'mms'

describe MMS::Resource::Group do
  let(:client) { MMS::Client.new }

  it 'should load data' do
    client.stub(:get).and_return(
        {
            "id" => "5196d3628d022db4cbc111111",
            "name" => "mms-group-1",
            "lastActiveAgent" => "2014-04-03T18:18:12Z",
            "activeAgentCount" => 1,
            "replicaSetCount" => 3,
            "shardCount" => 2,
        }
    )

    group = MMS::Resource::Group.find(client, '5196d3628d022db4cbc111111')

    group.id.should eq('5196d3628d022db4cbc111111')
    group.name.should eq('mms-group-1')
    group.shard_count.should eq(2)
  end

end
