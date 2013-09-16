require "rumm"
require "vcr"
require "aruba/api"
require "aruba/cucumber"
require "netrc"
$: << File.expand_path("../../app/providers", __FILE__)

Before do
  @aruba_timeout_seconds = 600
end

VCR.configure do |c|
  c.default_cassette_options = {:record => :once}
  c.hook_into :excon
  #c.debug_logger = $stderr

  c.cassette_library_dir = 'features/fixtures/cassettes'
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
