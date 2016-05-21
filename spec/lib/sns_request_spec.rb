require 'spec_helper'

RSpec.describe  SNSRequest do
  context 'new request' do
    describe 'write to es' do
      let(:body) {
        {foo: 'bar', baz: 'woo'}
      }

      let(:headers) {
        {'Content-Type' => 'bar',
         'Time' => 'woo'}
      }

      let(:time) { Time.now }

      it 'should write json to email_links/sns_requests' do
        sig = {
          index: 'email_links',
          type:  'sns_requests',
          body_hash:  {body: body, headers: headers, time: time}
        }
        expect(EsClient).to receive(:write).with(sig)
        SNSRequest.write_to_es(body: body, headers: headers, time: time)
      end
    end
  end
end
