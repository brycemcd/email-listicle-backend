require 'pp'
#require 'pry'
class ProcessLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(json)
    #binding.pry
    pl = RawEmail::Parse.new(json)
    #puts "---"
    #pl.email_links.each {|x| pp x}
    #puts "---"
    #pl.save_parsed_links
    fail 'done'

    FeatureEngineeringBatchWorker.perform_async
  end
end
