require 'mms'

describe MMS::Resource::Cluster do
  let(:client) { MMS::Client.new }
  let(:cluster) { MMS::Resource::Cluster.new(client, {'id' => '1', 'groupId' => '2'}) }

  it 'should reload data' do
    client.stub(:get).and_return(
        {
            "id" => "5196d3628d022db4cbc000000",
            "groupId" => "5196d3628d022db4cbc111111",
            "typeName" => "REPLICA_SET",
            "clusterName" => "Cluster of Animals",
            "shardName" => "shard001",
            "replicaSetName" => "rs1",
            "lastHeartbeat" => "2014-02-26T17:32:45Z",
        }
    )

    cluster.id.should eq('1')
    cluster.group.id.should eq('2')
    cluster.shard_name.should eq(nil)

    cluster.reload

    cluster.id.should eq('5196d3628d022db4cbc000000')
    cluster.shard_name.should eq('shard001')
    cluster.name.should eq('Cluster of Animals')
  end

end
