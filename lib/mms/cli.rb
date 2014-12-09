require 'slop'
require 'terminal-table'
require 'parseconfig'
require 'pathname'

module MMS

  class CLI

    NoOptionsError = Class.new(StandardError)

    class << self

      attr_accessor :options
      attr_accessor :option_processors
      attr_accessor :input_args

      attr_accessor :actions_available
      attr_accessor :app_name

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

      def parse_config
        config_file = Pathname.new(Dir.home) + '.' + @app_name
        if config_file.exist?
          config = ParseConfig.new(config_file)

          config.params.map do |key, value|
            MMS::Config.public_send("#{key}=", value)
          end
        end

        self
      end

      def parse_options(args=ARGV)
        unless options
          raise NoOptionsError, "No command line options defined! Use MMS::CLI.add_options to add command line options."
        end

        self.input_args = args

        self.parse_config

        begin
          opts = Slop.parse!(
              args,
              :help => true,
              :multiple_switches => false,
              :strict => true,
              &options
          )
        rescue Slop::InvalidOptionError,Slop::MissingArgumentError
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

MMS::CLI.app_name = 'mms-api'
MMS::CLI.actions_available = ["groups", "hosts", "clusters", "snapshots", "restorejobs", "restorejobs-create"]

MMS::CLI.add_options do

  app_dscr = "#{MMS::CLI.app_name} is a tool for accessing MMS API"
  app_usage = "#{MMS::CLI.app_name} command [options]"
  app_commands = "#{MMS::CLI.actions_available.join(' | ')}"

  banner("#{app_dscr}\n\nUsage:\n\n\t#{app_usage}\n\nCommands:\n\n\t#{app_commands}\n\nOptions:\n\n")

  on(:u, :username=, "MMS user") do |u|
    MMS::Config.username = u
  end
  on(:k, :apikey=, "MMS api-key") do |a|
    MMS::Config.apikey = a
  end
  on(:a, :apiurl=, "MMS api url. Full url including version: https://mms.mydomain.tld/api/public/v1.0") do |u|
    MMS::Config.apiurl = u
  end
  on(:g, :group_id=, "MMS group id") do |g|
    MMS::Config.group_id = g
  end
  on(:c, :cluster_id=, "MMS cluster id") do |c|
    MMS::Config.cluster_id = c
  end
  on(:i, :ignore, "Ignore flag of --group-id and -cluster-id", :default => false)
  on(:n, :name=, "Filter for resource name using regexp", :default => '')
  on(:l, :limit=, "Limit for result items", :as => Integer) do |l|
    MMS::Config.limit = l
  end

  on(:v, :version, "Version") do |v|
    puts "#{MMS::CLI.app_name} v#{MMS::VERSION}"
    exit
  end

end.add_option_processor do |options|
  exit if options.help?

  if options[:i]
    MMS::Config.group_id = nil
    MMS::Config.cluster_id = nil
  end
  if MMS::Config.username.nil?
    puts "Missing options: MMS username [-u <string>]"
    exit
  end
  if MMS::Config.apikey.nil?
    puts "Missing options: MMS api-key [-k <string>]"
    exit
  end

  begin
    action = (ARGV.first || MMS::Config.action || '').downcase
    raise("Unknown action #{action.upcase}") unless MMS::CLI.actions_available.include? (action)
  rescue => e
    puts "Error: #{e.message}"
    puts "Available actions: #{(MMS::CLI.actions_available.join ', ').upcase}"
    exit 1
  end

  begin
    ARGV.shift
    agent = MMS::Agent.new
    unless MMS::Config.apiurl.empty?
      agent.set_apiurl(MMS::Config.apiurl)
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
        results_sorted.first(MMS::Config.limit).each do |snapshot|
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
        results_sorted.first(MMS::Config.limit).each do |job|
          rows << [job.id, job.snapshot_id, job.name, job.status_name, job.point_in_time, job.delivery_method_name, job.delivery_status_name]
          rows << ['', "#{job.cluster.name} (#{job.cluster.id})", {:value => '', :colspan => 5}]
          rows << ['', job.cluster.group.name, {:value => '', :colspan => 5}]
          rows << [{:value => 'download url:', :colspan => 7}]
          rows << [{:value => job.delivery_url, :colspan => 7}]
          rows << :separator
        end
    end

    puts Terminal::Table.new :title => action.upcase, :headings => (heading.nil? ? [] : heading), :rows => rows

    puts 'Default group: ' + MMS::Config.group_id unless MMS::Config.group_id.nil?
    puts 'Default cluster: ' + MMS::Config.cluster_id unless MMS::Config.cluster_id.nil?

    if !MMS::Config.group_id.nil? or !MMS::Config.cluster_id.nil?
      puts 'Add flag --ignore or update --group-id, --cluster-id or update your `~/.mms-api` to see all resources'
    end

  rescue => e
    puts "Error: `#{e.message}`"
    exit 1
  end

end
