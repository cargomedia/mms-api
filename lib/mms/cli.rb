require 'clamp'
require 'parseconfig'

module MMS

  class CLI

    class MMS::CLI::Command < Clamp::Command

      attr_accessor :app_name
      attr_accessor :config

      attr_accessor :client
      attr_accessor :agent

      option ['-u', '--username'], '<string>', 'MMS user' do |u|
        @config.username = u
      end

      option ['-k', '--apikey'], '<string>', 'MMS api-key' do |a|
        @config.apikey = a
      end

      option ['-a', '--apiurl'], '<string>', 'MMS api url. Full url including version: https://mms.mydomain.tld/api/public/v1.0' do |u|
        @config.apiurl = u
      end

      option ['-v', '--version'], :flag, 'Version' do |v|
        puts "mms-api v#{MMS::VERSION}"
        exit
      end

      option ['-g', '--default-group-id'], '<string>', 'Default MMS group id' do |g|
        @config.default_group_id = g
      end

      option ['-c', '--default-cluster-id'], '<string>', 'Default MMS cluster id' do |c|
        @config.default_cluster_id = c
      end

      option ['--cfg'], '<string>', 'Config file path' do |p|
        @config.config_path = p
        parse_user_home_config
      end

      option ['-i', '--ignore'], :flag, 'Ignore flag of --group-id and -cluster-id', :default => false

      option ['-j', '--json'], :flag, 'Print JSON output', :default => false

      option ['-l', '--limit'], '<integer>', 'Limit for result items' do |l|
        @config.limit = Integer(l)
      end

      def initialize(invocation_path, context = {}, parent_attribute_values = {})
        @config ||= MMS::Config.new
      end

      def parse_user_home_config
        raise(MMS::ConfigError.new('Config file path is not set!')) if @config.config_path.nil?
        config_file = Pathname.new(@config.config_path)
        raise(MMS::ConfigError.new("Config file `#{config_file}` does not exist")) unless config_file.exist?

        config = ParseConfig.new(config_file)
        config.params.map do |key, value|
          begin
            @config.send("#{key}=", value)
          rescue Exception => e
            raise MMS::ConfigError.new("Config option `#{key}` from file `#{config_file}` is not allowed!")
          end
        end

      end

      def agent
        @client = MMS::Client.new(@config.username, @config.apikey)
        @agent = MMS::Agent.new(client)
      end

      def print(heading, resource_list)
        json? ? print_json(resource_list) : print_human(heading, resource_list)
      end

      def print_human(heading, resource_list)
        rows = []

        resource_list.first(@config.limit).each do |resource|
          rows += resource.table_section
        end

        puts Terminal::Table.new :title => 'Hosts', :headings => (heading.nil? ? [] : heading), :rows => rows

        print_tips unless ignore?
      end

      def print_json(resource_list)
        rows = []

        resource_list.first(@config.limit).each do |resource|
          rows.push(resource.to_hash)
        end

        puts JSON.pretty_generate(rows)
      end

      def print_tips
        puts 'Default group: ' + @config.default_group_id unless @config.default_group_id.nil?
        puts 'Default cluster: ' + @config.default_cluster_id unless @config.default_cluster_id.nil?

        if !@config.default_group_id.nil? or !@config.default_cluster_id.nil?
          puts "Add flag --ignore or update --default-group-id, --default-cluster-id or update your `#{@config.config_path}` to see all resources"
        end
      end

      def run(arguments)
        begin
          parse_user_home_config
          super
        rescue Clamp::HelpWanted => e
          raise(help)
        rescue Clamp::UsageError => e
          raise([e.message, help].join("\n"))
        rescue MMS::AuthError => e
          raise('Authorisation problem. Please check you credential!')
        rescue MMS::ResourceError => e
          raise(["Resource #{e.resource.class.name} problem:", e.message].join("\n"))
        end
      end
    end

    class MMS::CLI::Command::Hosts < MMS::CLI::Command

      self.default_subcommand = 'list'

      subcommand 'list', 'Host list' do

        def execute
          print(MMS::Resource::Host.table_header, agent.hosts)
        end
      end

    end

    class MMS::CLI::Command::Groups < MMS::CLI::Command

      self.default_subcommand = 'list'

      subcommand 'list', 'Group list' do

        def execute

          group_list = agent.groups
          group_list.reject! { |group| group.id != @config.default_group_id } unless @config.default_group_id.nil? or ignore?

          print(MMS::Resource::Group.table_header, group_list)
        end
      end

    end

    class MMS::CLI::Command::Clusters < MMS::CLI::Command

      self.default_subcommand = 'list'

      subcommand 'list', 'Cluster list' do

        def execute
          cluster_list = agent.clusters
          cluster_list.reject! { |cluster| cluster.id != @config.default_cluster_id } unless @config.default_cluster_id.nil? or ignore?

          print(MMS::Resource::Cluster.table_header, cluster_list)
        end
      end

    end


    class MMS::CLI::Command::Alerts < MMS::CLI::Command

      self.default_subcommand = 'list'

      subcommand 'list', 'Alerts list' do

        def execute
          print(MMS::Resource::Alert.table_header, agent.alerts)
        end

      end

      subcommand 'ack', 'Acknowledge alert' do

        parameter '[alert-id]', 'Alert ID', :default => 'all'
        parameter '[group-id]', 'Group ID', :default => '--default-group-id'
        parameter '[timestamp]', 'Postpone to timestamp', :default => 'forever'

        def execute
          g_id = group_id == '--default-group-id' ? @config.default_group_id : group_id
          agent.alert_ack(alert_id, timestamp, g_id)
          puts 'Done.'
        end

      end

    end

    class MMS::CLI::Command::Snapshots < MMS::CLI::Command

      self.default_subcommand = 'list'

      subcommand 'list', 'Snapshot list' do

        def execute
          print(MMS::Resource::Snapshot.table_header, agent.snapshots)
        end
      end

    end

    class MMS::CLI::Command::RestoreJobs < MMS::CLI::Command

      self.default_subcommand = 'list'

      subcommand 'list', 'Restorejob list' do

        def execute
          print(MMS::Resource::RestoreJob.table_header, agent.restorejobs)
        end

      end

      subcommand 'create', 'Restorejob create' do

        parameter '[snapshot-source]', 'Restore from source. Options: now | timestamp | snapshot-id', :default => 'now'
        parameter '[group-id]', 'Group ID', :default => '--default-group-id'
        parameter '[cluster-id]', 'Cluster ID', :default => '--default-cluster-id'

        def execute
          g_id = group_id == '--default-group-id' ? @config.default_group_id : group_id
          c_id = cluster_id == '--default-cluster-id' ? @config.default_cluster_id : cluster_id

          agent.restorejob_create(snapshot_source, g_id, c_id)

          puts 'Done.'
        end

      end

    end

    class MMS::CLI::CommandManager < MMS::CLI::Command

      def run(arguments)
        begin
          super
        rescue Exception => e
          abort(e.message.empty? ? 'Unknown error/Interrupt' : e.message)
        end
      end

      subcommand 'groups', 'Groups ', MMS::CLI::Command::Groups
      subcommand 'hosts', 'Hosts', MMS::CLI::Command::Hosts
      subcommand 'clusters', 'Clusters', MMS::CLI::Command::Clusters
      subcommand 'alerts', 'Alerts', MMS::CLI::Command::Alerts
      subcommand 'snapshots', 'Snapshots', MMS::CLI::Command::Snapshots
      subcommand 'restorejobs', 'Restorejobs', MMS::CLI::Command::RestoreJobs

    end

  end

end
