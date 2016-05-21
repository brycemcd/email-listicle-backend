require 'pp'
class ProcessLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(raw_email)
    pl = RawEmail::Parse.new(raw_email)
    # for debugging in production
    puts "---"
    pl.email_links.each {|x| pp x}
    puts "---"
    pl.save_parsed_links

    FeatureEngineeringBatchWorker.perform_async
  end
end
