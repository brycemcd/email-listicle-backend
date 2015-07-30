require_relative 'email-listicle'
require "rack/cors"

use Rack::Cors do
  allow do
    origins '*'
  end
end
run EmailListicle::API
