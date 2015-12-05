require 'dotenv'
Dotenv.load
Bundler.require

require_relative "../lib/base"

require 'sidekiq'

curdur = Dir.pwd
Dir.chdir("async")
require_relative "./aws_setup.rb"

Dir.glob("*.rb").each do |worker|
  require_relative "./#{worker}" unless worker =~ /base/
end
Dir.chdir(curdur)
