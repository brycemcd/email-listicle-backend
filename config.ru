require "rack/cors"
require_relative 'email-listicle'
require 'sidekiq/web'

use Rack::Cors do
  allow do
    origins '*'
    # TODO lock this down
    resource '*', :headers => :any, :methods => [:get, :post, :options, :put, :delete]
  end
end

use Rack::Session::Cookie, :secret => "some unique secret string here"
run Rack::URLMap.new('/' => EmailListicle::API,
                     '/sidekiq' => Sidekiq::Web)

