require 'spec_helper'

RSpec.describe EmailLinkRejection do
  let(:el) {
    el = EmailLink.new
    el.id = 'abc'
    el.title = 'hello world'
    el
  }

  let(:elr) {
    EmailLinkRejection.new(el)
  }

  describe 'init' do
    it 'takes an EmailLink object to initialize' do
      expect {
        EmailLinkRejection.new
      }.to raise_error(ArgumentError)
      expect {
        EmailLinkRejection.new([])
      }.to raise_error(ArgumentError)
    end
  end

  describe 'rejectable?' do
    it 'returns true if the link should not be rejected' do
      expect_any_instance_of(EmailLinkRejection).to receive(:find_duplicated_links).
        twice.and_return(false)

      expect(elr.rejectable?).to be_falsey
      expect(elr.reject_reasons).to be_empty
    end

    it 'rejects if number of words in title is below a threshold' do
      expect_any_instance_of(EmailLinkRejection).to receive(:find_duplicated_links).
        twice.and_return(false)

      el.cnt_title_words = (EmailLinkRejection::REJECT_WORD_COUNT_THRESHOLD - 1)
      elr = EmailLinkRejection.new(el)

      expect(elr.rejectable?).to be_truthy
      expect(elr.reject_reasons).to eql([:title_threshold])
    end

    it 'rejects if link title contains some magic reject words' do
      expect_any_instance_of(EmailLinkRejection).to receive(:find_duplicated_links).
        twice.and_return(false)

      el.title = 'unsubscribe from this email'
      elr = EmailLinkRejection.new(el)
      expect(elr.rejectable?).to be_truthy
      expect(elr.reject_reasons).to eql([:phrase])
    end

    it 'rejects if link title has been considered before' do
      expect_any_instance_of(EmailLinkRejection).to receive(:find_duplicated_links).
        and_return(true)

      expect(elr.rejectable?).to be_truthy
      expect(elr.reject_reasons).to eql([:duplicate_link])
    end

    it 'rejects if link title contains some magic reject words' do
      expect_any_instance_of(EmailLinkRejection).to receive(:find_duplicated_links).
        and_return(true)
      el.title = 'unsubscribe'
      el.cnt_title_words = (EmailLinkRejection::REJECT_WORD_COUNT_THRESHOLD - 1)
      elr = EmailLinkRejection.new(el)

      expect(elr.rejectable?).to be_truthy
      expect(elr.reject_reasons).to eql([
        :duplicate_link,
        :phrase,
        :title_threshold,
      ])
    end
  end

  describe '#reason_string' do
    it 'sorts and underscores the reject reasons' do
      expect_any_instance_of(EmailLinkRejection).to receive(:find_duplicated_links).
        and_return(true)

      el = EmailLink.new
      elr = EmailLinkRejection.new(el)

      expect(elr).to receive(:reject_reasons).and_return([
        :duplicate_link,
        :phrase,
        :title_threshold,
      ])

      expect(elr.reason_string).to eql('duplicate_link-phrase-title_threshold')
    end
  end
end
