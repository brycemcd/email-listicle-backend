class FeatureEngineeringWorker
  include Sidekiq::Worker

  def perform(email_link_id)
    el = EmailLink.find(email_link_id)
    el.cnt_title_words = word_count(el.title)
    result = el.update

    #TODO - auto rejecting needs to happen in a separate, out of (this)
    # loop, routine. For now, the only reliable thing we know is a title
    # less <= 4 words should be automatically rejected
    if el.cnt_title_words <= 4
      EmailLink.reject_from_reading_list(email_link_id)
    end
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
