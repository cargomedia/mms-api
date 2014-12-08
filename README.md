mms-api
=======
Minimalistic [MMS API](http://mms.mongodb.com/) agent for ruby

Installation
------------
```
gem install mms-api
```

Cli
---
```bash
$ mms-api --help
mms-api is a tool for accessing MMS API

Usage:

	mms-api command [options]

Commands:

	groups | hosts | clusters | snapshots | restorejobs | restorejobs-create

Options:

    -u, --username <string>           MMS user
    -k, --apikey <string>             MMS api-key
    -a, --apiurl <string>             MMS api url. Full url including version: https://mms.mydomain.tld/api/public/v1.0
    -n, --name <string>               Filter by resource name using regexp
    -l, --limit <int>                 Limit for result items
    -v, --version                     Version
    -h, --help                        Show this help
```

`mms-api` reads default configuration from your home directory `~/.mms-api`. Example configuration:

```
username=sysadmin@example.tld
apikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# apiurl=https://mms.mydomain.tld/api/public/v1.0
# action=hosts
```

API coverage
------------
The MMS Public API follows the principles of the REST architectural style to expose a number of internal resources which enable programmatic access to [MMS’s features](http://mms.mongodb.com/help/reference/api/). Current implementation support only a few of API features.

|Resource|Get All|Get One|Create|Update|Delete|
|:---|:---:|:---:|:---:|:---:|:---:|
|Groups| + | + | | | | |
|Hosts| + | + | | | | |
|Clusters| + | + | | | | |
|Snapshots| + | + | | | | |
|Restore Jobs| + | + | + | | | |


Example
-------
```ruby
require 'mms'

agent = MMS::Agent.new('username', 'apikey')

# all available resources
group_list = agent.groups
host_list = agent.hosts
cluster_list = agent.clusters
snapshot_list = agent.snapshots
job_list = agent.restorejobs

# get first cluster from list
cluster = cluster_list.first

# get list of all restore-jobs for specific cluster
job_list = agent.findGroup(cluster.group.id).cluster(cluster.id).restorejobs
# or simply using cluster instance
job_list = cluster.restorejobs

# get first snapshot from list
snapshot = snapshot_list.first

# create restore job for snapshot
group_id = snapshot.cluster.group.id
cluster_id = snapshot.cluster.id
snapshot_id = snapshot.id
job_list = agent.findGroup(group_id).cluster(cluster_id).snapshot(snapshot_id).create_restorejob
# or simply using snapshot instance
job_list = snapshot.create_restorejob
```
