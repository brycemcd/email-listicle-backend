class StoreLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(sns_json)
    top_level_json = JSON.parse(sns_json['Message'])

    ProcessLinksFromEmailWorker.perform_async(top_level_json['content'])
  end
end
