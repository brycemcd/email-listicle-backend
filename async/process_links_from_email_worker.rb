class ProcessLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(json)
    pl = Mandrill::ParseEmailLinks.new(json['msg'])
    pl.save_parsed_links

    FeatureEngineeringBatchWorker.perform_async
  end
end
