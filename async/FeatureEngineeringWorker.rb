class ProcessLinksFromEmailWorker
  include Sidekiq::Worker

  def perform(email_link_id)
    el = EmailLink.find(email_link_id)
    el.cnt_title_words = word_count(el.title)
    el.update
  end

  private

  def word_count(word)
    word.split.length
  end
end
