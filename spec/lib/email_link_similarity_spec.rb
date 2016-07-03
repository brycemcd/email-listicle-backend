require 'spec_helper'
require 'json'

RSpec.describe EmailLinkSimilarity do
  let(:el_1) {
    el = EmailLink.new
    el.id = 'abc'
    el.title = 'hello world'
    el
  }

  let(:el_2) {
    el = EmailLink.new
    el.id = 'def'
    el.title = 'hello world'
    el
  }

  let(:el_3) {
    el = EmailLink.new
    el.id = 'ghi'
    el.title = 'goodbye world'
    el
  }

  let(:search_results) {
    f = File.read(SPEC_BASE + "/support/es_search_result.json")
    JSON.parse(f) # returns hash
  }

  let(:els) {
    EmailLinkSimilarity.new(el_1)
  }

  describe "init" do
    it 'requires an email link for initialization' do
      els = EmailLinkSimilarity.new(el_1)
      expect(els.link_for_comparison).to be_kind_of EmailLink
    end
  end

  describe '#fetch_similar' do
    it 'queries ES for similar links based on title' do
      expect($es_client).to receive(:search).and_return(search_results)
      sim = els.fetch_similar
      expect(sim).to be_kind_of Array
      expect(sim.first).to be_kind_of EmailLink
    end

    #NOTE: this is from a production bug
    it 'returns an empty array if no title is available' do
      el = EmailLink.new
      els = EmailLinkSimilarity.new(el)
      expect(els.fetch_similar).to eql([])

      el = EmailLink.new
      el.title = ""
      els = EmailLinkSimilarity.new(el)
      expect(els.fetch_similar).to eql([])

      el = EmailLink.new
      el.title = "\n"
      els = EmailLinkSimilarity.new(el)
      expect(els.fetch_similar).to eql([])
    end
  end

  describe '#identical_links' do
    it 'finds email links that have identical title and are not link_for_comparison' do
      expect(els).to receive(:fetch_similar).and_return([el_1, el_2, el_3])

      sames = els.identical_links

      expect(sames).to eql([el_2])
    end

    it 'returns an empty array when presented with an empty array' do
      expect(els).to receive(:fetch_similar).and_return([])

      sames = els.identical_links

      expect(sames).to be_empty
    end
  end
end
