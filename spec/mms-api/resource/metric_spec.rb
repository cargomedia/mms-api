require 'mms'

describe MMS::Resource::Metric do
  let(:client) { MMS::Client.new }

  it 'should load data' do
    allow(client).to receive(:get).and_return(
      {
        'hostId' => '5196d3628d022db4cbc000000',
        'groupId' => '5196d3628d022db4cbc111111',
        'metricName' => 'OPCOUNTERS_UPDATE',
        'units' => 'RAW',
        'granularity' => 'MINUTE',
        'dataPoints' => [
          {
            'timestamp' => '2014-08-26T16:42:00Z',
            'value' => 10.3911
          }, {
            'timestamp' => '2014-08-26T16:43:00Z',
            'value' => 14.938
          }, {
            'timestamp' => '2014-08-26T16:44:00Z',
            'value' => 12.8882
          }
        ],
        'links' => {}
      },
      {
        'id' => '5196d3628d022db4cbc000000',
        'groupId' => '5196d3628d022db4cbc111111',
        'hostname' => 'localhost',
        'port' => 27017,
        'typeName' => 'SHARD_SECONDARY'
      },
      'id' => '5196d3628d022db4cbc111111',
      'name' => 'mms-group-1',
      'lastActiveAgent' => '2014-04-03T18:18:12Z',
      'activeAgentCount' => 1,
      'replicaSetCount' => 3,
      'shardCount' => 2
    )

    metric = MMS::Resource::Metric.find(client, '5196d3628d022db4cbc11111', '5196d3628d022db4cbc000000', 'OPCOUNTERS_UPDATE')

    expect(metric.host.id).to eq('5196d3628d022db4cbc000000')
    expect(metric.host.group.id).to eq('5196d3628d022db4cbc111111')
    expect(metric.name).to eq('OPCOUNTERS_UPDATE')
    expect(metric.granularity).to eq('MINUTE')
    expect(metric.units).to eq('RAW')
  end
end
