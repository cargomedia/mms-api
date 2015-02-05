mms-api [![Build Status](https://travis-ci.org/cargomedia/mms-api.png)](https://travis-ci.org/cargomedia/mms-api)
=======
Minimalistic [MMS API](http://mms.mongodb.com/) agent for ruby

Installation
------------
```
gem install mms-api
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
|Alerts| + | + | | | | |
|Restore Jobs| + | + | + | | | |

Config
------
```ruby
config = MMS::Config.new
```

Client
------
```ruby
client = MMS::Client.new(config.username, config.apikey)
```

Agent
-----
```ruby
agent = MMS::Agent.new(client)
```

Cli
---
```bash
$ mms-api --help
Usage:
     [OPTIONS] SUBCOMMAND [ARG] ...

Parameters:
    SUBCOMMAND                    subcommand
    [ARG] ...                     subcommand arguments

Subcommands:
    groups                        Groups
    hosts                         Hosts
    clusters                      Clusters
    alerts                        Alerts
    snapshots                     Snapshots
    restorejobs                   Restorejobs

Options:
    -h, --help                    print help
    -u, --username <string>       MMS user
    -k, --apikey <string>         MMS api-key
    -a, --apiurl <string>         MMS api url. Full url including version: https://mms.mydomain.tld/api/public/v1.0
    -v, --version                 Version
    -g, --default-group-id <string> Default MMS group id
    -c, --default-cluster-id <string> Default MMS cluster id
    --cfg <string>                Config file path
    -i, --ignore                  Ignore flag of --group-id and -cluster-id (default: false)
    -j, --json                    Print JSON output (default: false)
    -l, --limit <integer>         Limit for result items
```

`mms-api` reads default configuration from your home directory `~/.mms-api`. Example configuration:

```
username=sysadmin@example.tld
apikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
# apiurl=https://mms.mydomain.tld/api/public/v1.0
default_group_id=your-group-id
default_cluster_id=your-cluster-id
```
