class ProcessLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(json)
    pl = ParseEmailLinks.new(json['msg'])
    pl.save_parsed_links

    els = EmailLink.unengineered
    els.each do |el|
      FeatureEngineeringWorker.perform_async(el.id)
    end
  end
end
