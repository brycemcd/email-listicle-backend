require 'httparty'
require 'nokogiri'

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

class ParseEmailLinks
  class EmailLink
    attr_accessor :title, :url, :article_content

    def to_json(*args)
      { url: self.url,
        article_content: self.article_content,
        title: self.title
      }.to_json
    end
  end

  attr_reader :email_links

  def initialize(email_html_body)
    parsed = Nokogiri::HTML(email_html_body)
    @email_links = parsed.xpath('//a').collect do |link|
      next unless link['href'] =~ /http/
      el = EmailLink.new
      el.title = link.text
      el.url = link['href']
      #el.article_content = FetchArticleContent.new(link['href'])
      el
    end.compact
  end
end

#response = HTTParty.get('http://ng-newsletter.us6.list-manage.com/track/click?u=86d6f14c7cc955128485e3b8e&id=8cabdb99e9&e=c2ad06fd2c')
#response = HTTParty.get('http://rubyweekly.us1.list-manage.com/track/click?u=0618f6a79d6bb9675f313ceb2&id=1bb06d3aa9&e=59c980d683')
#response = HTTParty.get('http://rubyweekly.us1.list-manage.com/track/click?u=0618f6a79d6bb9675f313ceb2&id=9765b88476&e=59c980d683')

#fac = FetchArticleContent.new('http://rubyweekly.us1.list-manage.com/track/click?u=0618f6a79d6bb9675f313ceb2&id=9765b88476&e=59c980d683')
#puts fac.url_content
