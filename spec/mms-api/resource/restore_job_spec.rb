require 'mms'

describe MMS::Resource::RestoreJob do

  restorejob_data = {
      "id" => "3",
      "groupId" => "0",
      "clusterId" => "0",
      "snapshotId" => "0",
      "created" => "2014-07-09T17:42:43Z",
      "timestamp" => {
          "date" => "0",
          "increment" => 1
      },
      "statusName" => "OPEN",
      "pointInTime" => false,
      "links" => []
  }

  let(:client) { MMS::Client.new }
  let(:restorejob) { MMS::Resource::RestoreJob.new(client, restorejob_data) }

  it 'should reload data' do
    client.stub(:get).and_return(
        [{
             "id" => "0",
             "groupId" => "0",
             "typeName" => "REPLICA_SET",
             "clusterName" => "Cluster 0",
             "shardName" => "shard001",
             "replicaSetName" => "rs1",
             "lastHeartbeat" => "2014-02-26T17:32:45Z",
         }],
        {
            "id" => "3",
            "groupId" => "525ec8394f5e625c80c7404a",
            "clusterId" => "53bc556ce4b049c88baec825",
            "snapshotId" => "53bd439ae4b0774946a16490",
            "created" => "2014-07-09T17:42:43Z",
            "timestamp" => {
                "date" => "2014-07-09T09:24:37Z",
                "increment" => 1
            },
            "statusName" => "FINISHED",
            "pointInTime" => true,
            "delivery" => {
                "methodName" => "HTTP",
                "url" => "https://api-backup.mongodb.com/backup/restore/v2/pull/aaa/bbb/ccc/ddd-eee-fff.tar.gz",
                "expires" => "2014-07-09T18:42:43Z",
                "statusName" => "READY"
            },
            "links" => []
        },
    )

    restorejob.id.should eq('3')
    restorejob.status_name.should eq('OPEN')
    restorejob.point_in_time.should eq(false)

    restorejob.reload

    restorejob.id.should eq('3')
    restorejob.status_name.should eq('FINISHED')
    restorejob.point_in_time.should eq(true)

  end

end
