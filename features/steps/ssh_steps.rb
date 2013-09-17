Given "SSH is stubbed" do
  Fog::SSH.stub(:new) do |address, username, options = {}|
    Fog::SSH::Mock.new(address, username, options)
  end
end