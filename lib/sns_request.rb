class SNSRequest
  attr_reader :body, :headers

  ES_INDEX = 'email_links'
  ES_TYPE  = 'sns_requests'

  def self.write_to_es(body: nil, headers: nil, time: nil)
    EsClient.write(index: ES_INDEX,
                   type: ES_TYPE,
                   body_hash: { body: body,
                                headers: headers,
                                time: time}
                  )
  end
end
