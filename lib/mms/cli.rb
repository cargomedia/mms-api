require 'slop'
require 'terminal-table'
require 'parseconfig'
require 'pathname'
require 'clamp'

module MMS

  class CLI

    class MMS::CLI::Command < Clamp::Command

      attr_accessor :app_name
      attr_accessor :config

      attr_accessor :client
      attr_accessor :agent

      option ['-g', '--group-id'], "<string>", "MMS group id" do |g|
        @config.group_id = g
      end

      option ['-c', '--cluster-id'], "<string>", "MMS cluster id" do |c|
        @config.cluster_id = c
      end

      option ['-i', '--ignore'], :flag, "Ignore flag of --group-id and -cluster-id", :default => false

      option ['-l', '--limit'], "<integer>", "Limit for result items" do |l|
        @config.limit = l
      end

      def initialize(invocation_path, context = {}, parent_attribute_values = {})
        @config ||= MMS::Config.new

        parse_user_home_config
      end

      def parse_user_home_config
        config_file = Pathname.new(Dir.home) + ('.mms-api')
        if config_file.exist?
          config = ParseConfig.new(config_file)

          config.params.map do |key, value|
            @config.send("#{key}=", value)
          end
        end

        self
      end

      def agent
        @client = MMS::Client.new(@config.username, @config.apikey)
        @agent = MMS::Agent.new(client)
      end

      def print(heading, resource_list)
        rows = []

        resource_list.first(@config.limit).each do |resource|
          rows += resource.table_section
        end

        puts Terminal::Table.new :title => "Hosts", :headings => (heading.nil? ? [] : heading), :rows => rows

        puts 'Default group: ' + @config.group_id unless @config.group_id.nil?
        puts 'Default cluster: ' + @config.cluster_id unless @config.cluster_id.nil?

        if !@config.group_id.nil? or !@config.cluster_id.nil?
          puts 'Add flag --ignore or update --group-id, --cluster-id or update your `~/.mms-api` to see all resources'
        end
      end

    end

    class MMS::CLI::Command::Hosts < MMS::CLI::Command

      def execute
        print(MMS::Resource::Host.table_header, agent.hosts)
      end

    end

    class MMS::CLI::Command::Groups < MMS::CLI::Command

      def execute
        group_list = agent.groups
        group_list.reject! { |group| group.id != @config.group_id } unless @config.group_id.nil?

        print(MMS::Resource::Group.table_header, group_list)
      end

    end

    class MMS::CLI::Command::Clusters < MMS::CLI::Command

      def execute
        cluster_list = agent.clusters
        cluster_list.reject! { |cluster| cluster.id != @config.cluster_id } unless @config.cluster_id.nil?

        print(MMS::Resource::Cluster.table_header, cluster_list)
      end

    end


    class MMS::CLI::Command::Alerts < MMS::CLI::Command

      class MMS::CLI::Command::Alerts::List < MMS::CLI::Command

        def execute
          print(MMS::Resource::Alert.table_header, agent.alerts)
        end

      end

      class MMS::CLI::Command::Alerts::Ack < MMS::CLI::Command

        parameter "[id]", "Alert ID", :default => 'all'
        parameter "[timestamp]", "Postpone to timestamp", :default => 'forever'

        def execute
        end

      end

      self.default_subcommand = "list"

      subcommand 'list', 'Alerts list', MMS::CLI::Command::Alerts::List
      subcommand 'ack', 'Acknowledge alert', MMS::CLI::Command::Alerts::Ack

    end

    class MMS::CLI::Command::Snapshots < MMS::CLI::Command

      def execute
        print(MMS::Resource::Snapshot.table_header, agent.snapshots)
      end

    end

    class MMS::CLI::Command::RestoreJobs < MMS::CLI::Command

      class MMS::CLI::Command::RestoreJobs::List < MMS::CLI::Command

        def execute
          print(MMS::Resource::RestoreJob.table_header, agent.restorejobs)
        end

      end

      class MMS::CLI::Command::RestoreJobs::Create < MMS::CLI::Command

        parameter "[snapshot-source]", "Restore from source. Options: now | timestamp | snapshot-id", :default => 'now'

        def execute
        end

      end

      self.default_subcommand = "list"

      subcommand 'list', 'Alerts list', MMS::CLI::Command::RestoreJobs::List
      subcommand 'create', 'Acknowledge alert', MMS::CLI::Command::RestoreJobs::Create

    end

    class MMS::CLI::CommandManager < Clamp::Command

      option ['-u', '--username'], "<string>", "MMS user" do |u|
        @config.username = u
      end

      option ['-k', '--apikey'], "<string>", "MMS api-key" do |a|
        @config.apikey = a
      end

      option ['-a', '--apiurl'], "<string>", "MMS api url. Full url including version: https://mms.mydomain.tld/api/public/v1.0" do |u|
        @config.apiurl = u
      end

      option ['-v', '--version'], :flag, "Version" do |v|
        puts "mms-api v#{MMS::VERSION}"
        exit
      end

      subcommand 'groups', 'Groups list', MMS::CLI::Command::Groups
      subcommand 'hosts', 'Hosts list in the mms group', MMS::CLI::Command::Hosts
      subcommand 'clusters', 'Clusters list in the mms groups', MMS::CLI::Command::Clusters
      subcommand 'alerts', 'Alerts list', MMS::CLI::Command::Alerts
      subcommand 'snapshots', 'Snapshot lists', MMS::CLI::Command::Snapshots
      subcommand 'restorejobs', 'Restorejobs list', MMS::CLI::Command::RestoreJobs
    end

  end

end
