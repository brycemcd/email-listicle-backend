require 'grape'
require_relative 'email-listicle'

namespace :grape do
  desc 'Print compiled grape routes'
  task :routes do
    EmailListicle::V1::API.routes.each do |route|
      puts route
    end
  end
end
