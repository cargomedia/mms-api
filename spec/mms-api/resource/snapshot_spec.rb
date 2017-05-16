require 'mms'

describe MMS::Resource::Snapshot do
  let(:client) { MMS::Client.new }

  it 'should load data' do
    allow(client).to receive(:get).and_return(
      {
        'id' => '003',
        'groupId' => '001',
        'clusterId' => '002',
        'created' => {
          'date' => '2014-02-01T12:34:12Z',
          'increment' => 54
        },
        'expires' => '2014-08-01T12:34:12Z',
        'complete' => true,
        'isPossiblyInconsistent' => false
      },
      {
        'id' => '002',
        'groupId' => '001',
        'typeName' => 'REPLICA_SET',
        'clusterName' => 'Cluster of Animals',
        'shardName' => 'shard001',
        'replicaSetName' => 'rs1',
        'lastHeartbeat' => '2014-02-26T17:32:45Z'
      },
      'id' => '001',
      'name' => 'mms-group-1',
      'lastActiveAgent' => '2014-04-03T18:18:12Z',
      'activeAgentCount' => 1,
      'replicaSetCount' => 3,
      'shardCount' => 2
    )

    snapshot = MMS::Resource::Snapshot.find(client, '1', '2', '3', '4')

    expect(snapshot.id).to eq('003')
    expect(snapshot.cluster.id).to eq('002')
    expect(snapshot.cluster.group.id).to eq('001')
    expect(snapshot.complete).to be true
    expect(snapshot.name).to eq('2014-02-01 12:34:12')
  end
end
