class EmailLink
  attr_accessor :title, :url, :article_content, :id,
    :email_subject, :created_at

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
    }
  end

  def save
    es = EsClient.new(YAML_CONFIG, nil)
    es.write(type: 'email_link',
             body_hash: self.as_hash)
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

  def self.reject_from_reading_list(id)
    es = EsClient.new(YAML_CONFIG, nil)
    es.update(id, accepted: false, accept_or_reject_dttm: DateTime.now.iso8601)
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

  def self.unread
    es = EsClient.new(YAML_CONFIG, 'unread')
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
    el
  end
end
