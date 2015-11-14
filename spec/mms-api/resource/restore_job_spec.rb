require 'mms'

describe MMS::Resource::RestoreJob do
  let(:client) { MMS::Client.new }

  it 'should load data' do
    client.stub(:get).and_return(
      'id' => '3',
      'groupId' => '525ec8394f5e625c80c7404a',
      'clusterId' => '53bc556ce4b049c88baec825',
      'snapshotId' => '53bd439ae4b0774946a16490',
      'created' => '2014-07-09T17:42:43Z',
      'timestamp' => {
        'date' => '2014-07-09T09:24:37Z',
        'increment' => 1
      },
      'statusName' => 'FINISHED',
      'pointInTime' => true,
      'delivery' => {
        'methodName' => 'HTTP',
        'url' => 'https://api-backup.mongodb.com/backup/restore/v2/pull/aaa/bbb/ccc/ddd-eee-fff.tar.gz',
        'expires' => '2014-07-09T18:42:43Z',
        'statusName' => 'READY'
      },
      'links' => []
    )

    restorejob = MMS::Resource::RestoreJob.find(client, '5196d3628d022db4cbc111111', '5196d3628d022db4cbc000000', '3', '4')

    restorejob.id.should eq('3')
    restorejob.status_name.should eq('FINISHED')
    restorejob.point_in_time.should eq(true)
  end
end
