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

  #NOTE: This is causing problems in LinkSimilarity but doesn't appear
  # to affect anything else in the system. It should probably be moved to
  # some sort of pre-persistence check
  def cleansed_title
    self.title.gsub(/[\t\r\n\f]/, '')
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
      self.class.reject_from_reading_list(el.id, reason: 'already seen', reject_automatic: true)
    end
  end

  def update
    es = EsClient.new(YAML_CONFIG, nil)
    es.update(self.id, self.as_hash)
  end

  def autoreject?
    elr = link_rejector
    elr.rejectable?
  end

  private def link_rejector
    @link_rejector ||= EmailLinkRejection.new(self)
  end

  def autoreject!
    reject = link_rejector
    self.class.reject_from_reading_list(self.id,
                                       reason: reject.reason_string,
                                       reject_automatic: true)
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

  def self.reject_from_reading_list(id, reason: 'none given', reject_automatic: false)
    es = EsClient.new(YAML_CONFIG, nil)
    es.update(id,
              accepted: false,
              reject_automatic: reject_automatic,
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
