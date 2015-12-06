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

|Resource       |Get All |Get One |Create |Update |Delete |
|:--------------|:------:|:------:|:-----:|:-----:|:-----:|
|Groups         | +      | +      |       |       |       |
|Hosts          | +      | +      | +     | +     |+      |
|Clusters       | +      | +      |       | +     |       |
|Snapshots      | +      | +      |       |       |       |
|Alerts         | +      | +      |       |       |       |
|Restore Jobs   | +      | +      | +     |       |       |
|Backup Configs | +      | +      |       |       |       |
|Metrics        | +      | +      |       |       |       |

Library usage
-------------

Source code itself is well-documented so when writing code it should auto-complete and hint in all supported usages.


### Client
Most important part of the api is client. In order to make any request you need to instantiate client with correct params.

```ruby
client = MMS::Client.new('username', 'api_key')
```

This client is used by all other classes connecting to api no matter if it's Resource or helper class like Agent.


### Agent
Agent is simple wrapper class for listing all accessible resources.

```ruby
client = MMS::Client.new('username', 'api_key')
agent = MMS::Agent.new(client)

agent.alerts.each do |alert|
    alert.ack('now')
end
```

List of resource-listing agent methods:
- groups
- hosts
- clusters
- snapshots
- alerts
- restorejobs

### Resources

You can find lists of resource by using agent as pointed above, or by various resource methods.
Each resource have a find method loading certain resource with provided id (plus corresponding parent ids), e.g.
```ruby
client = new MMS::Client.new('username', 'api_key')
host = MMS::Resource::Host.find(client, 'group_id', 'host_id')
```

Additionally some resources have additional instance methods to retrieve sub-resources, e.g.
```ruby
client = new MMS::Client.new('username', 'api_key')
group = MMS::Resource::Group.find(client, 'group_id')
hosts = group.hosts
```

#### Metrics

(Not available via CLI)

You can list the available metrics on each host. The list contains the resource type MMS::Resource::Metric. This can be used to see which performance metrics the host has.

In order to get the metric's data points you'll need to call the specific function.

Note - you can send a hash containing query parameter. With no input it uses MMS default.

The return value of the data points is the hash described in MMS's API reference docs.
```ruby
client = new MMS::Client.new('username', 'api_key')
host = MMS::Resource::Host.find(client, 'group_id', 'host_id')
metrics = host.metrics
options = {"granularity" => "HOUR", "period" => "P1DT12H" }
metrics.each do |m|
  puts m.data_points(options)
end
```
In case of hardware or database metrics, the return value will be an array that each value contains the data points for the relevant device or database.

Cli usage
---------

There is a built-in cli with several commands retrieving api resource lists.

### Configuration

Cli uses configuration with all values set to default ones.
Config itself has `config_file` property which merges itself with params from the file.
By default `config_file` points to home directory, but it can be changed to points to any file.

```
username=sysadmin@example.tld
apikey=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
apiurl=https://mms.mydomain.tld/api/public/v1.0
default_group_id=your-group-id
default_cluster_id=your-cluster-id
```

Additionally some options can be modified using cli options.

### Available commands


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
