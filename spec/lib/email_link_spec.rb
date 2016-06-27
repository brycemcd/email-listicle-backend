require 'spec_helper'
require 'json'

RSpec.describe EmailLink do
  let(:search_results) {
    f = File.read(SPEC_BASE + "/support/es_search_result.json")
    JSON.parse(f) # returns hash
  }

  context 'finding similar articles' do
    describe '#similar' do
      it 'queries ES with the same title' do
        el = EmailLink.new
        el.title = "hello world"

        expect($es_client).to receive(:search).and_return(search_results)
        sim = el.similar
        expect(sim).to be_kind_of Array
        expect(sim.first).to be_kind_of EmailLink
      end
    end
  end

  describe "#same_title" do
    it 'finds email links that have identical titles' do
      el_base = EmailLink.new
      el_base.id = 'abc'
      el_base.title = "hello world"

      el_same = EmailLink.new
      el_same.id = 'def'
      el_same.title = "hello world"

      el_diff = EmailLink.new
      el_diff.id = 'ghi'
      el_diff.title = "goodbye world"

      sames = el_base.identical_email_links([el_base, el_same, el_diff])
      expect(sames).to eql([el_same])
    end
  end

  describe "#reject_identical_links!" do
    #TODO: update ES mapping!
    it 'rejects links with the same title with a good reason code' do
      el_base = EmailLink.new
      el_base.title = "hello world"

      el_same = EmailLink.new
      el_same.id = 'abc'
      el_same.title = "hello world"

      #FIXME - without this, a roundtrip to ES is executed
      expect($es_client).to receive(:search).and_return(search_results)
      expect(el_base).to receive(:identical_email_links).and_return([el_same])
      expect(EmailLink).to receive(:reject_from_reading_list).with(el_same.id, reason: 'already seen').and_return(true)

      el_base.reject_identical_links!
    end
  end
end
