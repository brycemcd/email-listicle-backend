require 'spec_helper'
require 'json'

RSpec.describe EmailLink do
  let(:el) {
    el = EmailLink.new
    el.id = 'abc'
    el.title = 'hello world from here'
    el.cnt_title_words = 4
    el
  }
  describe '#autoreject?' do
    it 'allows EmailLinkRejection to handle all auto reject concerns' do
      expect_any_instance_of(EmailLinkRejection).to receive(:rejectable?).
        twice.and_return(false)

      el.autoreject?
    end
  end

  describe '#autoreject!' do
    it 'calls .reject_from_reading_list with the reject reasons' do
      reject = double(:email_link_rejection, reason_string: 'foo')

      expect(el).to receive(:link_rejector).and_return(reject)
      expect(EmailLink).to receive(:reject_from_reading_list).with(
        el.id,
        reason: reject.reason_string,
        reject_automatic: true
      )
      el.autoreject!
    end
  end

  describe '#cleansed_title' do
    it 'removes non-printable characters' do
      el.title = "2 \n comments\t from \r\n people"
      expect(el.cleansed_title).to eql('2  comments from  people')
    end
  end
end
