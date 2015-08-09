class RejectLinkFromReadingListWorker
  include Sidekiq::Worker

  def perform(id)
    EmailLink.reject_from_reading_list(id)
  end
end
