require 'mms'

describe MMS::Resource::Host do
  let(:client) { MMS::Client.new }

  it 'should load data' do
    allow(client).to receive(:get).and_return(
      'id' => '56e9378f601dc49360a40949c8a6df6c',
      'groupId' => '5196d3628d022db4cbc111111',
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

    host = MMS::Resource::Host.find(client, '5196d3628d022db4cbc111111', '56e9378f601dc49360a40949c8a6df6c')

    expect(host.id).to eq('56e9378f601dc49360a40949c8a6df6c')
    expect(host.hostname).to eq('localhost')
    expect(host.port).to eq(26000)
  end
end
