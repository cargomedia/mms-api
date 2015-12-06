require 'mms'

describe MMS::Resource::Host do
  let(:client) { MMS::Client.new }

  it 'should load data' do
    client.stub(:get).and_return(
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

    host.id.should eq('56e9378f601dc49360a40949c8a6df6c')
    host.hostname.should eq('localhost')
    host.port.should eq(26000)
  end
end
