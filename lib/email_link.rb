class EmailLink
  attr_accessor :title, :url, :article_content

  def to_json(*args)
    as_hash.to_json
  end

  def as_hash
    { url: self.url,
      article_content: self.article_content,
      title: self.title
    }
  end

  def save
    $es_client.index(index: 'email_links', type: 'email_link', body: self.as_hash)
  end

  def self.all
    $es_client.search(index: 'email_links', body: {})['hits']['hits'].map do |result|
      result = result['_source']
      el = EmailLink.new
      el.url = result['url']
      el.title = result['title']
      el
    end
  end

  def self.undecided
    $es_client.search(index: 'email_links', body: {filter: {missing: {field: :accepted}}})['hits']['hits'].map do |result|
      result = result['_source']
      el = EmailLink.new
      el.url = result['url']
      el.title = result['title']
      el
    end
  end
end
