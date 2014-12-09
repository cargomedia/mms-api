require 'slop'
require 'terminal-table'
require 'pathname'

module MMS

  class CLI

    NoOptionsError = Class.new(StandardError)

    class << self

      attr_accessor :config

      attr_accessor :options

      attr_accessor :option_processors

      attr_accessor :input_args

      def config
        @config ||= MMS::Config.new
      end

      def add_options(&block)
        self.options = block
        self
      end

      def reset
        self.options = nil
        self.option_processors = nil
      end

      def add_option_processor(&block)
        self.option_processors ||= []
        option_processors << block

        self
      end

      def parse_options(args=ARGV)
        unless options
          raise NoOptionsError, "No command line options defined! Use MMS::CLI.add_options to add command line options."
        end

        self.input_args = args

        begin
          opts = opts = Slop.parse!(
              args,
              :help => true,
              :multiple_switches => false,
              :strict => true,
              &options
          )
        rescue Slop::InvalidOptionError
          # Display help message on unknown switches and exit.
          puts Slop.new(&options)
          exit
        end

        # Option processors are optional.
        if option_processors
          option_processors.each { |processor| processor.call(opts) }
        end

        self
      end
    end
  end
end

actions_available = ["groups", "hosts", "clusters", "snapshots", "restorejobs", "restorejobs-create"]

app_name = 'mms-api'
app_dscr = "#{app_name} is a tool for accessing MMS API"
app_usage = "#{app_name} command [options]"
app_version = MMS::VERSION
app_commands = "#{actions_available.join(' | ')}"

config = Hash.new {|h, k| nil}
config_file = Pathname.new(Dir.home) + app_name.prepend('.')
if config_file.exist?
  config = ParseConfig.new(config_file)

  config.params.map do |key, value|
    MMS::CLI.config.public_send("#{key}=", value)
  end
end

MMS::CLI.add_options do
  banner("#{app_dscr}\n\nUsage:\n\n\t#{app_usage}\n\nCommands:\n\n\t#{app_commands}\n\nOptions:\n\n")

  on(:u, :username=, "MMS user") do |u|
    MMS::CLI.config.username = u
  end
  on(:k, :apikey=, "MMS api-key") do |a|
    MMS::CLI.config.apikey = a
  end
  on(:a, :apiurl=, "MMS api url. Full url including version: https://mms.mydomain.tld/api/public/v1.0") do |u|
    MMS::CLI.config.apiurl = u
  end
  on(:g, :group_id=, "MMS group id") do |g|
    MMS::CLI.config.group_id = g
  end
  on(:c, :cluster_id=, "MMS cluster id") do |c|
    MMS::CLI.config.cluster_id = c
  end
  on(:i, :ignore, "Ignore flag of --group-id and -cluster-id", :default => false)
  on(:n, :name=, "Filter for resource name using regexp", :default => '')
  on(:l, :limit=, "Limit for result items", :as => Integer) do |l|
    MMS::CLI.config.limit = l
  end

  on(:v, :version, "Version") do |v|
    puts "#{app_name} v#{app_version}"
    exit
  end

end.add_option_processor do |options|
  exit if options.help?

  if options[:i] == true
    MMS::CLI.config.group_id = nil
    MMS::CLI.config.cluster_id = nil
  end
  if MMS::CLI.config.username.nil?
    puts "Missing options: MMS username [-u <string>]"
    exit
  end
  if MMS::CLI.config.apikey.nil?
    puts "Missing options: MMS api-key [-k <string>]"
    exit
  end

  begin
    action = (ARGV.first || config['action'] || '').downcase
    raise("Unknown action #{action.upcase}") unless actions_available.include? (action)
  rescue => e
    puts "Error: #{e.message}"
    puts "Available actions: #{(actions_available.join ', ').upcase}"
    puts optparse
    exit 1
  end

  begin
    ARGV.shift
    agent = MMS::Agent.new(MMS::CLI.config.username, MMS::CLI.config.apikey, MMS::CLI.config.group_id, MMS::CLI.config.cluster_id)
    unless MMS::CLI.config.apiurl.empty?
      agent.set_apiurl(MMS::CLI.config.apiurl)
    end

    results = agent.send action.sub('-', '_'), *ARGV
    results.select! { |resource| !resource.name.match(Regexp.new(options[:name])).nil? }

    rows = []
    case action
      when 'groups'
        heading = ['Name', 'Active Agents', 'Replicas count', 'Shards count', 'Last Active Agent', 'GroupId']
        results.each do |group|
          rows << [group.name, group.active_agent_count, group.replicaset_count, group.shard_count, group.last_active_agent, group.id]
        end
      when 'hosts'
        heading = ['Group', 'Type', 'Hostname', 'IP', 'Port', 'Last ping', 'Alerts enabled', 'HostId', 'Shard', 'Replica']
        results.each do |host|
          rows << [host.group.name, host.type_name, host.name, host.ip_address, host.port, host.last_ping, host.alerts_enabled, host.id, host.shard_name, host.replicaset_name]
        end
      when 'clusters'
        heading = ['Group', 'Cluster', 'Shard name', 'Replica name', 'Type', 'Last heartbeat', 'Cluster Id']
        results.each do |cluster|
          rows << [cluster.group.name, cluster.name, cluster.shard_name, cluster.replicaset_name, cluster.type_name, cluster.last_heartbeat, cluster.id]
        end
      when 'snapshots'
        heading = ['Group', 'Cluster', 'SnapshotId', 'Complete', 'Created increment', 'Name (created date)', 'Expires']
        results_sorted = results.sort_by { |snapshot| snapshot.created_date }.reverse
        results_sorted.first(MMS::CLI.config.limit).each do |snapshot|
          rows << [snapshot.cluster.group.name, snapshot.cluster.name, snapshot.id, snapshot.complete, snapshot.created_increment, snapshot.name, snapshot.expires]
          rows << :separator
          part_count = 0
          snapshot.parts.each do |part|
            file_size_mb = part['fileSizeBytes'].to_i / (1024*1024)
            rows << [{:value => "part #{part_count}", :colspan => 4, :alignment => :right}, part['typeName'], part['replicaSetName'], "#{file_size_mb} MB"]
            part_count += 1
          end
          rows << :separator
        end
      when 'restorejobs', 'restorejobs-create'
        heading = ['RestoreId', 'SnapshotId / Cluster / Group', 'Name (created)', 'Status', 'Point in time', 'Delivery', 'Restore status']
        results_sorted = results.sort_by { |job| job.created }.reverse
        results_sorted.first(MMS::CLI.config.limit).each do |job|
          rows << [job.id, job.snapshot_id, job.name, job.status_name, job.point_in_time, job.delivery_method_name, job.delivery_status_name]
          rows << ['', "#{job.cluster.name} (#{job.cluster.id})", {:value => '', :colspan => 5}]
          rows << ['', job.cluster.group.name, {:value => '', :colspan => 5}]
          rows << [{:value => 'download url:', :colspan => 7}]
          rows << [{:value => job.delivery_url, :colspan => 7}]
          rows << :separator
        end
    end

    puts Terminal::Table.new :title => action.upcase, :headings => (heading.nil? ? [] : heading), :rows => rows

    puts 'Default group: ' + MMS::CLI.config.group_id unless MMS::CLI.config.group_id.nil?
    puts 'Default cluster: ' + MMS::CLI.config.cluster_id unless MMS::CLI.config.cluster_id.nil?

    if !MMS::CLI.config.group_id.nil? or !MMS::CLI.config.cluster_id.nil?
      puts 'Add flag --ignore or update --group-id, --cluster-id or update your `~/.mms-api` to see all resources'
    end

  rescue => e
    puts "Error: `#{e.message}`"
    exit 1
  end

end
