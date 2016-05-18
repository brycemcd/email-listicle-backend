class ProcessLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(json)
    pl = RawEmail::Parse.new(json['content'])
    pl.save_parsed_links

    FeatureEngineeringBatchWorker.perform_async
  end
end
