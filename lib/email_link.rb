class EmailLink
  attr_accessor :title, :url, :article_content, :id,
    :email_subject, :created_at, :from_email, :from_name, :cnt_title_words,
    :accept_or_reject_dttm, :accepted

  YAML_CONFIG = 'email_links.yml'

  def to_json(*args)
    as_hash.to_json
  end

  def as_hash
    { id: self.id,
      url: self.url,
      article_content: self.article_content,
      title: self.title,
      email_subject: self.email_subject,
      created_at: self.created_at,
      from_name: self.from_name,
      from_email: self.from_email,
      cnt_title_words: self.cnt_title_words,
      accept_or_reject_dttm: self.accept_or_reject_dttm,
      accepted: self.accepted
    }
  end

  # TODO - this should be create, not save
  def save
    es = EsClient.new(YAML_CONFIG, nil)
    es.write(type: 'email_link',
             body_hash: self.as_hash)
  end

  def reject_identical_links!
    il = self.identical_email_links(self.similar())
    il.each do |el|
      self.class.reject_from_reading_list(el.id, reason: 'already seen')
    end
  end

  def identical_email_links(comparison_email_links)
    comparison_email_links.select { |cel| identical_link?(self, cel) }
  end

  private def identical_link?(link_1, link_2)
    link_1.title == link_2.title &&
      link_1.id != link_2.id
  end

  def similar
    es = EsClient.new(YAML_CONFIG, nil)
    search = $es_client.search(index: es.query_index,
                                body: similar_search_hash)

    search['hits']['hits'].map do |result|
      self.class.parse_from_result(result)
    end
  end

  private def similar_search_hash
    {
      size: 16,
      query: {
        match: {
          title: self.title
        }
      }
    }
  end

  def update
    es = EsClient.new(YAML_CONFIG, nil)
    es.update(self.id, self.as_hash)
  end

  def autoreject?
    !more_than_word_count_threshold? ||
      contains_auto_reject_phrase?
  end

  AUTOREJECT_WORD_COUNT_THRESHOLD = 3
  private def more_than_word_count_threshold?
    self.cnt_title_words && self.cnt_title_words > AUTOREJECT_WORD_COUNT_THRESHOLD
  end

  private def contains_auto_reject_phrase?
    self.title =~ /(unsubscribe)|(read more stories on .*Quibb*)/i
  end

  def autoreject!
    self.class.reject_from_reading_list(self.id)
  end

  def check_and_reject
    self.autoreject! if self.autoreject?
  end

  def self.find(id)
    es = EsClient.new(YAML_CONFIG, nil)
    doc = es.get_with_id(id)
    parse_from_result(doc)
  end

  def self.add_to_reading_list(id)
    es = EsClient.new(YAML_CONFIG, nil)
    es.update(id, accepted: true, accept_or_reject_dttm: DateTime.now.iso8601)
    find(id)
  end

  def self.whoops
    es = EsClient.new(YAML_CONFIG, 'whoops')
    es.search['hits']['hits'].map do |result|
      parse_from_result(result)
    end
  end

  def self.reject_from_reading_list(id, reason: 'none given')
    es = EsClient.new(YAML_CONFIG, nil)
    es.update(id,
              accepted: false,
              accept_or_reject_dttm: DateTime.now.iso8601,
              reject_reason: reason)
  end

  def self.all
    es = EsClient.new(YAML_CONFIG, 'all')
    es.search['hits']['hits'].map do |result|
      parse_from_result(result)
    end
  end

  def self.undecided
    es = EsClient.new(YAML_CONFIG, 'undecided')
    es.search['hits']['hits'].map do |result|
      parse_from_result(result)
    end
  end

  def self.clean_up_undecided!
    self.undecided.each { |el| el.check_and_reject }
  end

  def self.unread
    es = EsClient.new(YAML_CONFIG, 'unread')
    es.search['hits']['hits'].map do |result|
      parse_from_result(result)
    end
  end

  def self.unengineered
    es = EsClient.new(YAML_CONFIG, 'unengineered')
    es.search['hits']['hits'].map do |result|
      parse_from_result(result)
    end
  end

  def self.parse_from_result(result)
    id = result['_id']
    result = result['_source']

    el = EmailLink.new
    el.url = result['url']
    el.title = result['title']
    el.id = id
    el.created_at = result['created_at']
    el.email_subject = result['email_subject']
    el.from_email  = result['from_email']
    el.from_name   = result['from_name']
    el.cnt_title_words   = result['cnt_title_words']
    el.accept_or_reject_dttm   = result['accept_or_reject_dttm']
    el.accepted   = result['accepted']
    el
  end
end
