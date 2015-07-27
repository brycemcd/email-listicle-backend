$es_client = Elasticsearch::Client.new(log: true,
                                       host: ENV['ES_URL'])
