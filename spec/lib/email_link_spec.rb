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
      el.title = "2 \n comments\t from \r\n people:"
      expect(el.cleansed_title).to eql('2  comments from  people')

      el.title = "@psycherror"
      expect(el.cleansed_title).to eql('psycherror')
    end
  end

  describe '#set_title_word_count' do
    before(:each) do
      expect(el).to receive(:update).
                      at_least(:once).
                      at_most(:twice).
                      and_return(true)
    end

    it 'counts the number of words in the title and updates itself' do
      el.title = "Hello World"
      expect(el.set_title_word_count).to eql(2)

      el.title = "cats about dogs"
      expect(el.set_title_word_count).to eql(3)
    end

    it 'handles the nil case without blowing up' do
      el.title = nil
      expect(el.set_title_word_count).to eql(0)
    end
  end

  describe '#get_title_word_count' do
    it 'counts the number of words in the title and updates itself' do
      el.title = "Hello World"
      expect(el.get_title_word_count).to eql(2)

      el.title = "cats about dogs"
      expect(el.get_title_word_count).to eql(3)
    end

    it 'handles the nil case without blowing up' do
      el.title = nil
      expect(el.get_title_word_count).to eql(0)
    end
  end
end
