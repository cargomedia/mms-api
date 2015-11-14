require 'mms'

describe MMS::Resource::Cluster do
  let(:client) { MMS::Client.new }

  it 'should load data' do
    client.stub(:get).and_return(
      {
        'id' => '5196d3628d022db4cbc000000',
        'groupId' => '5196d3628d022db4cbc111111',
        'typeName' => 'REPLICA_SET',
        'clusterName' => 'Cluster of Animals',
        'shardName' => 'shard001',
        'replicaSetName' => 'rs1',
        'lastHeartbeat' => '2014-02-26T17:32:45Z'
      },
      'id' => '5196d3628d022db4cbc111111',
      'name' => 'mms-group-1',
      'lastActiveAgent' => '2014-04-03T18:18:12Z',
      'activeAgentCount' => 1,
      'replicaSetCount' => 3,
      'shardCount' => 2
    )

    cluster = MMS::Resource::Cluster.find(client, '5196d3628d022db4cbc11111', '5196d3628d022db4cbc000000')

    cluster.id.should eq('5196d3628d022db4cbc000000')
    cluster.group.id.should eq('5196d3628d022db4cbc111111')
    cluster.shard_name.should eq('shard001')
    cluster.name.should eq('Cluster of Animals')
  end
end
