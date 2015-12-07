class StoreLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(json_string)
    msgs = JSON.parse(json_string)

    msgs.each do |json|
      ProcessLinksFromEmailWorker.perform_async(json)
    end
  end

end
