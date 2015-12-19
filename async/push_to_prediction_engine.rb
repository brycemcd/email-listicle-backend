require 'predictionio'

class PushToPredictionEngine
  include Sidekiq::Worker

  def perform(email_link_id)
    el = EmailLink.find(email_link_id)
    write_to_events_server(el)
  end

  def write_to_events_server(email_link_obj)
    prediction_client.create_event(
      "listicle",
      "doc",
      el.id,
      {properties: el.as_json}
    )
  end

  def prediction_client
    @preidiction_client ||= PredictionIO::EventClient.new(ENV['PIO_ACCESS_KEY'],
                                                          ENV['PIO_EVENT_SERVER_URL'],
                                                          Integer(ENV['PIO_THREADS']))
  end
end
