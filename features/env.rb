require "rumm"
require "vcr"
require "aruba/api"
require "aruba/cucumber"
require "netrc"
require "fog"
require "cucumber/rspec/doubles"
$: << File.expand_path("../../app/providers", __FILE__)

Before do
  @aruba_timeout_seconds = 600
end

VCR.cucumber_tags do |t|
  t.tag  '@vcr', :use_scenario_name => true
end

VCR.configure do |c|
  c.default_cassette_options = {:record => :once}
  c.hook_into :excon

  c.cassette_library_dir = 'features/fixtures/cassettes'
  c.before_record do |interaction, cassette|
    # Throw away build state - just makes server.wait_for loops really long during replay
    begin
      json = JSON.parse(interaction.response.body)
      if json['server']['status'] == 'BUILD'
        # Ignoring interaction because server is in BUILD state
        interaction.ignore!
      end
    rescue
    end
  end
  c.filter_sensitive_data("<rackspace-username>") do |interaction|
    if interaction.response.body =~ /"username":"(\w+)"/ or interaction.request.body =~ /"username":"(\w+)"/
      $1
    else
      ENV['RACKSPACE_USERNAME']
    end
  end
  c.filter_sensitive_data("<rackspace-password>") do |interaction|
    if interaction.response.body =~ /"password":"(.+)"/ or interaction.request.body =~ /"password":"(.+)"/
      $1
    else
      ENV['RACKSPACE_PASSWORD']
    end
  end
  c.filter_sensitive_data("<rackspace-api-token>") do |interaction|
    if interaction.response.body =~ /"token":{"id":"(\w+)"/
      $1
    elsif token = interaction.request.headers['X-Auth-Token']
      token.first
    end
  end
  c.filter_sensitive_data("<rackspace-api-key>") do |interaction|
    if interaction.response.body =~ /"apiKey":"(\w+)"/ or interaction.request.body =~ /"apiKey":"(\w+)"/
      $1
    else
      ENV['RACKSPACE_API_KEY']
    end
  end
end

require "aruba/in_process"
require_relative "../app"
Aruba.process = Aruba::InProcess
class Aruba::InProcess
  attr_reader :stdin

  def self.main_class;
    @@main_class;
  end

  self.main_class = Class.new do
    @@input = ""
    class << self
      def input
        @@input
      end
    end

    def initialize(argv, stdin=STDIN, stdout=STDOUT, stderr=STDERR, kernel=Kernel)
      @argv, @stdin, @stdout, @stderr, @kernel = argv, stdin, stdout, stderr, kernel

      def @stdin.noecho
        yield self
      end

      @stdin << @@input
      @stdin.rewind
    end

    def execute!
      @kernel.exit Rumm::App.main @argv, @stdin, @stdout, @stderr
    end
  end
end
