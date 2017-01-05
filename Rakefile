require_relative 'email-listicle'

namespace :grape do
  desc 'Print compiled grape routes'
  task :routes do
    EmailListicle::API.routes.each do |route|
      puts route
    end
  end
end

namespace :links do
  desc 'process unprocessed links'
  task :engineer_links do
    EmailLink.unengineered.each do |email_link|
      LinkFilter.new.perform(email_link.id)
    end
  end
end
