require "bundler/setup"
require "mvcli/app"

module Rax
  class App < MVCLI::App
    self.root = Pathname(__FILE__).dirname
  end
end
