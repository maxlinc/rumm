if ENV['MOCK_WITH'] == 'pacto'
  require "pacto"
else
  require "vcr"
end

module InteractionStub

  extend self

  def configure
    if is_pacto?
      configure_pacto
    else
      configure_vcr
    end
  end

  def use_file(file_name, &block)
    if is_pacto?
      Pacto.use(file_name)
      block.call
    else
      VCR.use_cassette(file_name) do 
        block.call
      end
    end
  end

  def recording?
    if is_pacto?
      false
    else
      VCR.current_cassette.recording?
    end
  end

  def is_pacto?
    ENV['MOCK_WITH'] == 'pacto'
  end

  def configure_pacto
    Pacto.configure do |c|
      c.strict_matchers = false
      c.contracts_path = 'spec/fixtures/contracts'
    end
    Pacto.load_all 'authentication', 'https://identity.api.rackspacecloud.com', :default
    Pacto.load_all 'unsuccessful-authentication', 'https://identity.api.rackspacecloud.com', 'authentication/unsuccessful-login'
  end

  def configure_vcr
  VCR.configure do |c|
    c.default_cassette_options = {:record => :once}
    c.hook_into :excon

    c.cassette_library_dir = 'spec/fixtures/cassettes'
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
  end
end
