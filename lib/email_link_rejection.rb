class EmailLinkRejection
  attr_reader :email_link, :reject_bool, :reject_reasons

  REJECT_WORD_COUNT_THRESHOLD = 3

  def initialize(email_link)
    wrong_arguments unless email_link.is_a?(EmailLink)
    @email_link = email_link
    @reject_reasons = []
    rejectable?
  end

  def rejectable?
    @reject_reasons = []
    @reject_reasons << :title_threshold if less_than_word_count_threshold?
    @reject_reasons << :phrase if contains_auto_reject_phrase?
    @reject_reasons << :duplicate_link if duplicated_link?
    @reject_reasons.sort!
    @reject_reasons.any?
  end

  def reason_string
    self.reject_reasons.sort.join('-')
  end

  private def less_than_word_count_threshold?
    self.email_link.cnt_title_words &&
      self.email_link.cnt_title_words < REJECT_WORD_COUNT_THRESHOLD
  end

  private def contains_auto_reject_phrase?
    self.email_link.title =~ /(unsubscribe)|(read more stories on .*Quibb*)/i
  end

  private def duplicated_link?
    @duplicated_links ||= find_duplicated_links
  end

  private def find_duplicated_links
    els = EmailLinkSimilarity.new(self.email_link)
    els.identical_links.any?
  end

  private def wrong_arguments
    fail ArgumentError, "#{self.class.name} takes an EmailLink as a argument"
  end
end
