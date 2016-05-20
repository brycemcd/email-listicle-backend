class LinkFilter
  include Sidekiq::Worker

  def perform(email_link_id)
    el = EmailLink.find(email_link_id)
    el.cnt_title_words = word_count(el.title)
    result = el.update
    el.check_and_reject

    # FIXME / TODO:
    # reenable this infrastructure
    #if autoreject?(el)
      #EmailLink.reject_from_reading_list(email_link_id)
    #end
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

  def autoreject?(el)
    resp = HTTParty.post( "#{ENV['PIO_FILTER_SERVER_URL']}/queries.json",
                 body: {text: el.title}.to_json,
                 headers: { 'Content-Type' => 'application/json' })
    resp["category"] == "reject"
  end
end
