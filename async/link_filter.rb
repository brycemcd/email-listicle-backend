class LinkFilter
  include Sidekiq::Worker

  def perform(email_link_id)
    begin
      el = EmailLink.find(email_link_id)
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      Bugsnag.notify(e)
      puts "[ERROR] LinkFilter can not find #{email_link_id}"
      return true
    end

    el.cnt_title_words = word_count(el.title)
    result = el.update
    el.check_and_reject

    result
  end

  private

  def word_count(word)
    begin
      word.split.length
    rescue # if it doesn't respond to #split, I don't want to know it
      0
    end
  end
end
