require 'mail'
module RawEmail
  class Parse
    attr_reader :email_links

    def initialize(raw_text)
      mail = Mail.read_from_string(raw_text)
      parsed = find_html_and_parse(mail)
      parse_links(parsed, mail)
    end

    def save_parsed_links
      self.email_links.collect { |el| el.save }
    end

    private

    def parse_html_email(decoded_body)
      Nokogiri::HTML(decoded_body)
    end

    def find_html_and_parse(mail_obj)
      if mail_obj.multipart?
        mail_obj.parts.each do |part|
          next unless part.content_type =~ /html/
          return parse_html_email(part.body.decoded)
        end
      else
        parse_html_email(mail_obj.body.decoded)
      end
    end

    def parse_links(html_body, mail_obj)
      @email_links = html_body.xpath('//a').collect do |link|
        next if !link['href'] =~ /http/ || link.text.empty?
        el = EmailLink.new
        el.title = link.text
        el.url = link['href']
        el.email_subject = mail_obj.subject
        el.from_email = mail_obj.from.first
        el.from_name = "" # NOTE: doesn't come with mail. Not important for now
        el.created_at = DateTime.now.iso8601
        el
      end.compact
    end
  end
end
