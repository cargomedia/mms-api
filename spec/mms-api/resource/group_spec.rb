require 'mms'

describe MMS::Resource::Group do
  let(:client) { MMS::Client.new }

  it 'should load data' do
    allow(client).to receive(:get).and_return(
      'id' => '5196d3628d022db4cbc111111',
      'name' => 'mms-group-1',
      'lastActiveAgent' => '2014-04-03T18:18:12Z',
      'activeAgentCount' => 1,
      'replicaSetCount' => 3,
      'shardCount' => 2
    )

    group = MMS::Resource::Group.find(client, '5196d3628d022db4cbc111111')

    expect(group.id).to eq('5196d3628d022db4cbc111111')
    expect(group.name).to eq('mms-group-1')
    expect(group.shard_count).to eq(2)
  end

  it 'should return dedicated cache_key name for group resource' do
    group = MMS::Resource::Group.new

    expect(group.send(:cache_key, 'mygroup')).to eq('Class::MMS::Resource::Group:mygroup')
  end
end
