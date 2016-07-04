require 'bugsnag'

# Janky way to set app version that does not depend on Heroku
gh_client = Octokit::Client.new
c = gh_client.commits  'brycemcd/email-listicle-backend', :master
# commits are sorted with earliest first
version = c.first.sha

# perhaps the worst place to set an ENV variable
ENV['BUGSNAG_REVISION'] = version

Bugsnag.configure do |config|
  config.api_key = ENV['BUGSNAG_API_KEY']
  config.project_root = Dir.pwd
  config.release_stage = ENV['RACK_ENV'] || 'development'
  config.use_ssl = true
  config.notify_release_stages = ["production"]
  config.app_version = version
end

at_exit do
  if $!
    Bugsnag.notify($!)
  end
end
