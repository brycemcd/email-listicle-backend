require 'spec_helper'
require 'rack/test'

RSpec.describe EmailListicle::API, type: :request do
  include Rack::Test::Methods

  def app
    EmailListicle::API
  end

  let(:base_uri) { '/api/v1' }
  let(:el) {
    el = EmailLink.new
    el.id = 'abc'
    el.title = 'hello world from here'
    el
  }

  describe 'PUT :id/set_title_word_count' do
    let(:id) { 123 }
    let(:uri) { "#{base_uri}/email_links/#{id}/set_title_word_count" }

    context 'when id exists' do
      it 'calls set_title_word_count' do
        expect(EmailLink).to receive(:find).with(id.to_s).and_return(el)
        expect(el).to receive(:set_title_word_count).and_return(true)

        put uri

        expect(last_response.status).to eql(200)
        expect(last_response.body).to_not be_empty
      end
    end

    context 'when id does not exist' do
      it 'returns 404' do
        expect(EmailLink).to receive(:find).
                              and_raise(Elasticsearch::Transport::Transport::Errors::NotFound)
        expect(el).to_not receive(:set_title_word_count)

        put uri

        expect(last_response.status).to eql(404)
      end
    end

  end
end
