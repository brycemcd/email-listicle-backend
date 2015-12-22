require 'predictionio'

class PushToPredictionEngine
  include Sidekiq::Worker

  def perform(email_link_id)
    el = EmailLink.find(email_link_id)
    write_to_events_server(el)
  end

  def write_to_events_server(email_link_obj, prediction_client)
    prediction_client.create_event(
      "listicle",
      "doc",
      email_link_obj.id,
      {properties: email_link_obj.as_json}
    )
  end

  def self.prediction_client
    @preidiction_client ||= PredictionIO::EventClient.new(ENV['PIO_ACCESS_KEY'],
                                                          ENV['PIO_EVENT_SERVER_URL'],
                                                          Integer(ENV['PIO_THREADS']))
  end

  def self.bootstrap
    els = EmailLink.all
    pred_client = self.prediction_client
    els.each do |el|
      begin
        @i ||= 0
        puts self.new.write_to_events_server(el, pred_client)
      rescue => e
        @i += 1
        puts e.message
        puts e.class
        if @i > 10
          fail e
        else
          sleep(10)
          retry
        end
      end
    end
  end
end
