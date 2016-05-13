require 'spec_helper'

RSpec.describe RawEmail::Parse do
  let(:raw_email) { File.read(SPEC_BASE + "/support/emails/example_email.txt") }

  describe "initialization" do
    let(:re) { RawEmail::Parse.new(raw_email) }
    it "parses out the body of the email and populates an array of EmailLinks" do
      el = re.email_links
      expect(el).to be_kind_of Array
      expect(el.first).to be_kind_of EmailLink

      ex_el = el.first
      [:title, :url, :email_subject, :from_email, :created_at].each do |meth|
        expect(ex_el.public_send(meth)).to_not be_blank
      end
      expect(el.length).to eql(59)
    end
  end
end
