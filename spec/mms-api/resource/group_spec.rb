require 'mms'

describe MMS::Resource::Group do
  let(:client) { MMS::Client.new }
  let(:group) { MMS::Resource::Group.new(client, {'id' => '1'}) }

  it 'should reload data' do
    client.stub(:get).and_return(
        {
            "id" => "5196d3628d022db4cbc11111",
            "name" => "mms-group-1",
            "lastActiveAgent" => "2014-04-03T18:18:12Z",
            "activeAgentCount" => 1,
            "replicaSetCount" => 3,
            "shardCount" => 2,
        }
    )

    group.id.should eq('1')
    group.reload
    group.id.should eq('5196d3628d022db4cbc11111')
    group.name.should eq('mms-group-1')
  end

end
