require 'spec_helper'
require 'json'

RSpec.describe EmailLink do
  describe '#autoreject?' do
    let(:unrejectable_link) {
      el = EmailLink.new
      el.title = 'a perfectly valid title'
      el.cnt_title_words = (EmailLink::AUTOREJECT_WORD_COUNT_THRESHOLD + 1)
      el
    }

    it 'does not reject unrejectable_link' do
      expect(unrejectable_link).to receive(:duplicated_link?).and_return(false)
      expect(unrejectable_link.autoreject?).to be_falsey
    end

    it 'rejects if number of words in title is below a threshold' do
      unrejectable_link.cnt_title_words = (EmailLink::AUTOREJECT_WORD_COUNT_THRESHOLD - 1)
      expect(unrejectable_link.autoreject?).to be_truthy
    end

    it 'rejects if the title contains the word unsubscribe' do
      unrejectable_link.title = 'unsubscribe from this email'
      expect(unrejectable_link.autoreject?).to be_truthy
    end

    it 'rejects if the link title is duplicated' do
      expect(unrejectable_link).to receive(:duplicated_link?).and_return(true)
      expect(unrejectable_link.autoreject?).to be_truthy
    end
  end
end
