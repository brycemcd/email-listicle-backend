class AddLinkToReadingListWorker
  include Sidekiq::Worker

  def perform(id)
    el = EmailLink.add_to_reading_list(id)
    TrelloInterface.add_to_todo(el)
  end
end
