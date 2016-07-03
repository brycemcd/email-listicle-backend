class EmailLinkSimilarity
  attr_reader :link_for_comparison

  def initialize(link_for_comparison)
    @link_for_comparison = link_for_comparison
  end

  def fetch_similar
    return [] if title_unsearchable?
    es = EsClient.new('email_link_similarity.yml',
                      'similar_search_hash',
                      {title: self.link_for_comparison.title})

    es.search['hits']['hits'].map do |result|
      EmailLink.parse_from_result(result)
    end
  end

  def identical_links
    self.fetch_similar.select { |cel| identical_link?(self.link_for_comparison, cel) }
  end

  private def identical_link?(link_1, link_2)
    link_1.title == link_2.title &&
      link_1.id != link_2.id
  end

  private def title_unsearchable?
    title = self.link_for_comparison.title
    title.nil? || title.strip.empty?
  end
end
