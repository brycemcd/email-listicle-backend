module Mandrill
  class ParseEmailLinks
    attr_reader :email_links

    def initialize(email)
      parsed = Nokogiri::HTML(email['html'])
      @email_links = parsed.xpath('//a').collect do |link|
        next unless link['href'] =~ /http/
        el = EmailLink.new
        el.title = link.text
        el.url = link['href']
        el.email_subject = email['subject']
        el.from_email = email['from_email']
        el.from_name = email['from_name']
        el.created_at = DateTime.now.iso8601
        #el.article_content = FetchArticleContent.new(link['href'])
        el
      end.compact
    end

    def save_parsed_links
      self.email_links.collect { |el| el.save }
    end
  end
end
