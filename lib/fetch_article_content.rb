require 'httparty'

class FetchArticleContent
  attr_reader :url, :url_content
  def initialize(url)
    @url = url
    @url_content = fetch_content
  end


  private

  def fetch_content
    response = HTTParty.get(self.url)

    response.body
  end
end
