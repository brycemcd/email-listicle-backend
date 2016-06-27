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
end
