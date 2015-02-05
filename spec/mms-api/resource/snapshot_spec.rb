require 'mms'

describe MMS::Resource::Snapshot do
  let(:client) { MMS::Client.new }
  let(:snapshot) { MMS::Resource::Snapshot.new(client, {'id' => '1', 'groupId' => '2', 'clusterId' => '3'}) }

  it 'should reload data' do
    client.stub(:get).and_return(
        {
            "id" => "5196d3628d022db4cbc000000",
            "groupId" => "2847387cd717dabc348a",
            "clusterId" => "348938fbdbca74718cba",
            "created" => {
                "date" => "2014-02-01T12:34:12Z",
                "increment" => 54
            },
            "expires" => "2014-08-01T12:34:12Z",
            "complete" => true,
            "isPossiblyInconsistent" => false,
        }
    )

    snapshot.id.should eq('1')
    snapshot.cluster.id.should eq('3')
    snapshot.cluster.group.id.should eq('2')
    snapshot.complete.should eq(nil)
    snapshot.name.should eq('1')

    snapshot.reload

    snapshot.id.should eq('5196d3628d022db4cbc000000')
    snapshot.complete.should eq(true)
    snapshot.name.should eq('2014-02-01 12:34:12')
  end

end
