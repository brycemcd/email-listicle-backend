require 'dotenv'
Dotenv.load
Bundler.require

require_relative "../lib/base"

require 'sidekiq'
require "bugsnag/sidekiq"

curdur = Dir.pwd

Dir.chdir("async")
Dir.glob("*.rb").each do |worker|
  require_relative "./#{worker}" unless worker =~ /base/
end
Dir.chdir(curdur)
