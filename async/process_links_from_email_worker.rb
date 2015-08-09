class ProcessLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(json)
    pl = ParseEmailLinks.new(json['msg'])
    pl.save_parsed_links
  end
end
