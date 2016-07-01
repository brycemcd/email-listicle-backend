class EmailLinkSimilarity
  attr_reader :link_for_comparison

  def initialize(link_for_comparison)
    @link_for_comparison = link_for_comparison
  end

  def fetch_similar
    es = EsClient.new(EmailLink::YAML_CONFIG, nil)
    search = $es_client.search(index: es.query_index,
                                body: similar_search_hash)

    search['hits']['hits'].map do |result|
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

  private def similar_search_hash
    #FIXME: move this out to yaml
    {
      size: 16,
      filter: {
        bool: {
          must_not: [
            {
              missing: {
                field: "accepted"
              }
            }
          ]
        }
      },
      query: {
        match: {
          title: self.link_for_comparison.title
        }
      }
    }
  end

end
