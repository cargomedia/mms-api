require 'mms'

describe MMS::Resource::BackupConfig do
  let(:client) { MMS::Client.new }

  it 'should load data' do
    allow(client).to receive(:get).and_return(
      {
        'groupId' => '5196d3628d022db4cbc11111',
        'clusterId' => '5196d3628d022db4cbc000000',
        'statusName' => 'STARTED',
        'storageEngineName' => 'WIRED_TIGER',
        'authMechanismName' => 'MONGODB_CR',
        'username' => 'johnny5',
        'password' => 'guess!',
        'sslEnabled' => false,
        'syncSource' => 'PRIMARY',
        'provisioned' => true,
        'excludedNamespaces' => ['a', 'b', 'c.d']
      },
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

    backup_config = MMS::Resource::BackupConfig.find(client, '5196d3628d022db4cbc11111', '5196d3628d022db4cbc000000')

    expect(backup_config.cluster.id).to eq('5196d3628d022db4cbc000000')
    expect(backup_config.cluster.group.id).to eq('5196d3628d022db4cbc111111')
    expect(backup_config.status_name).to eq('STARTED')
    expect(backup_config.is_active).to be true
  end
end
