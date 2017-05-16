require 'mms'

describe MMS::Agent do
  let(:client) { MMS::Client.new }
  let(:agent) { MMS::Agent.new(client) }

  it 'should list all mms groups' do
    allow(client).to receive(:get).and_return(
      [{
        'id' => '5196d3628d022db4cbc11111',
        'name' => 'mms-group-1',
        'lastActiveAgent' => '2014-04-03T18:18:12Z',
        'activeAgentCount' => 1,
        'replicaSetCount' => 3,
        'shardCount' => 2
      },
       {
         'id' => '5196d3628d022db4cbc22222',
         'name' => 'mms-group-2',
         'lastActiveAgent' => '2014-04-03T11:18:12Z',
         'activeAgentCount' => 1,
         'replicaSetCount' => 3,
         'shardCount' => 2
       }]
    )

    group_list = agent.groups

    expect(group_list.length).to eq(2)
  end

  it 'should list hosts' do
    allow(client).to receive(:get).and_return(
      [{
        'id' => '5196d3628d022db4cbc11111',
        'name' => 'mms-group-1',
        'lastActiveAgent' => '2014-04-03T18:18:12Z',
        'activeAgentCount' => 1,
        'replicaSetCount' => 3,
        'shardCount' => 2
      }],
      [{
        'id' => '56e9378f601dc49360a40949c8a6df6c',
        'groupId' => '5196d3628d022db4cbc11111',
        'hostname' => 'localhost',
        'port' => 26000,
        'deactivated' => false,
        'sslEnabled' => true,
        'logsEnabled' => false,
        'created' => '2014-04-22T19:56:50Z',
        'hostEnabled' => true,
        'journalingEnabled' => false,
        'alertsEnabled' => true,
        'profilerEnabled' => false
      }]
    )

    host_list = agent.hosts

    expect(host_list.length).to eq(1)
    expect(host_list.first.id).to eq('56e9378f601dc49360a40949c8a6df6c')
    expect(host_list.first.group.id).to eq('5196d3628d022db4cbc11111')
  end

  it 'should create a host' do
    allow(client).to receive(:post).and_return(
      'id' => '56e9378f601dc49360a40949c8a6df6c',
      'groupId' => '5196d3628d022db4cbc11111',
      'hostname' => 'localhost',
      'port' => 26000,
      'deactivated' => false,
      'sslEnabled' => true,
      'logsEnabled' => false,
      'created' => '2014-04-22T19:56:50Z',
      'hostEnabled' => true,
      'journalingEnabled' => false,
      'alertsEnabled' => true,
      'profilerEnabled' => false
    )

    new_host = agent.host_create('5196d3628d022db4cbc11111',
                                 'localhost',
                                 26000,
                                 sslEnabled: true)

    expect(new_host.hostname).to eq('localhost')
    expect(new_host.port).to eq(26000)
    expect(new_host.alerts_enabled).to be true
    expect(new_host.profiler_enabled).to be false
    expect(new_host.logs_enabled).to be false
  end

  it 'should patch a host' do
    allow(client).to receive(:patch).and_return(
      'id' => '56e9378f601dc49360a40949c8a6df6c',
      'groupId' => '5196d3628d022db4cbc11111',
      'hostname' => 'localhost',
      'port' => 26000,
      'deactivated' => false,
      'sslEnabled' => true,
      'logsEnabled' => true,
      'created' => '2014-04-22T19:56:50Z',
      'hostEnabled' => true,
      'journalingEnabled' => false,
      'alertsEnabled' => true,
      'profilerEnabled' => false
    )

    updated_host = agent.host_update('5196d3628d022db4cbc11111',
                                     '56e9378f601dc49360a40949c8a6df6c',
                                     sslEnabled: true,
                                     logsEnabled: true)

    expect(updated_host.hostname).to eq('localhost')
    expect(updated_host.port).to eq(26000)
    expect(updated_host.alerts_enabled).to be true
    expect(updated_host.profiler_enabled).to be false
    expect(updated_host.logs_enabled).to be true
  end

  it 'should delete a host' do
    allow(client).to receive(:delete).and_return({})

    delete_ret = agent.host_delete('5196d3628d022db4cbc11111',
                                   '56e9378f601dc49360a40949c8a6df6c')

    expect(delete_ret).to be true
  end

  it 'should patch a cluster' do
    allow(client).to receive(:patch).and_return(
      'id' => '533d7d4730040be257defe88',
      'groupId' => '5196d3628d022db4cbc11111',
      'typeName' => 'SHARDED_REPLICA_SET',
      'clusterName' => 'Animals2',
      'lastHeartbeat' => '2014-04-03T15:26:58Z',
      'links' => []
    )

    updated_cluster = agent.cluster_update('5196d3628d022db4cbc11111',
                                           '533d7d4730040be257defe88',
                                           'Animals2')

    expect(updated_cluster.name).to eq('Animals2')
  end

  it 'should list snapshots' do
    allow(client).to receive(:get).and_return(
      [{
        'id' => '5196d3628d022db4cbc11111',
        'name' => 'mms-group-1',
        'lastActiveAgent' => '2014-04-03T18:18:12Z',
        'activeAgentCount' => 1,
        'replicaSetCount' => 3,
        'shardCount' => 2
      }],
      [{
        'id' => '533d7d4730040be257defe88',
        'groupId' => '5196d3628d022db4cbc11111',
        'typeName' => 'SHARDED_REPLICA_SET',
        'clusterName' => 'Animals',
        'lastHeartbeat' => '2014-04-03T15:26:58Z',
        'links' => []
      }],
      [{
        'id' => '53bd5fb5e4b0774946a16fad',
        'groupId' => '5196d3628d022db4cbc11111',
        'clusterId' => '533d7d4730040be257defe88',
        'created' => {
          'date' => '2014-07-09T15:24:37Z',
          'increment' => 1
        },
        'expires' => '2014-07-11T15:24:37Z',
        'complete' => true,
        'parts' => [{
          'typeName' => 'REPLICA_SET',
          'clusterId' => '533d7d4730040be257defe88',
          'replicaSetName' => 'rs0',
          'mongodVersion' => '2.6.3',
          'dataSizeBytes' => 17344,
          'storageSizeBytes' => 10502144,
          'fileSizeBytes' => 67108864
        }]
      }]
    )

    snapshot_list = agent.snapshots

    expect(snapshot_list.length).to eq(1)

    snapshot_first = snapshot_list.first
    expect(snapshot_first.id).to eq('53bd5fb5e4b0774946a16fad')
    expect(snapshot_first.cluster.id).to eq('533d7d4730040be257defe88')
    expect(snapshot_first.cluster.group.id).to eq('5196d3628d022db4cbc11111')

    expect(snapshot_first.is_cluster).to be false
    expect(snapshot_first.is_replica).to be true
    expect(snapshot_first.replica_name).to eq('rs0')
  end

  it 'should override API end point' do
    api_endpoint = client.url
    agent.apiurl('http://some.example.com:8080/api/public/v1.0')

    expect(client.url).to eq('http://some.example.com:8080/api/public/v1.0')

    agent.apiurl(api_endpoint) # setting to previous value as this is singleton
  end
end
