require_relative 'email-listicle'

namespace :grape do
  desc 'Print compiled grape routes'
  task :routes do
    EmailListicle::API.routes.each do |route|
      puts route
    end
  end
end
