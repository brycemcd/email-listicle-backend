require_relative 'email-listicle'
require "rack/cors"

use Rack::Cors do
  allow do
    origins '*'
    # TODO lock this down
    resource '*', :headers => :any, :methods => [:get, :post, :options]
  end
end
run EmailListicle::API
