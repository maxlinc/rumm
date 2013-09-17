require "rumm"
require "vcr"
require "fog_filters"
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
  c.allow_http_connections_when_no_cassette = true
  c.register_filter(FogFilters::RackspaceConfidential)
  c.register_filter(FogFilters::BuildingServers)

  c.cassette_library_dir = 'features/fixtures/cassettes'
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
