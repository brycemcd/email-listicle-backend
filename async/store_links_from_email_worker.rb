require 'dotenv'
Dotenv.load
Bundler.require

require 'sidekiq'
class StoreLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(json_string)
    msgs = JSON.parse(json_string)

    msgs.each do |json|
      pl = ParseEmailLinks.new(json['msg'])
      pl.save_parsed_links
    end
  end
end
