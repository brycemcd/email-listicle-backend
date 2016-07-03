require 'elasticsearch'
require 'yaml'
require 'erb'

$es_client = Elasticsearch::Client.new(log: true,
                                       host: ENV['ES_URL'])

class EsClient
  attr_reader :config_file, :root_key, :query_hash, :query_interpolations

  def initialize(config_file, root_key, query_interpolations={})
    @config_file = config_file
    @root_key = root_key
    @query_interpolations = query_interpolations
  end

  def write(type: nil, body_hash: nil)
    $es_client.index(index: query_index,
                     type: type,
                     body: body_hash)

  end

  def self.write(index: nil, type: nil, body_hash: nil)
    $es_client.index(index: index,
                     type: type,
                     body: body_hash)

  end

  def update(id, params)
    $es_client.update(id: id,
                      index: query_index,
                      type: full_config_file['type'],
                      body: {doc: params })
  end

  def get_with_id(id)
    $es_client.get(index: query_index,
                   type: full_config_file['type'],
                   id: id)
  end

  def search
    $es_client.search(index: query_index,
                      type: full_config_file['type'],
                      body: get_config_hash)
  end

  def get_config_hash
    @query_hash ||= read_config_file[root_key]
  end

  def query_index
    full_config_file['index']
  end

  def full_config_file
    @full_config_file ||= read_config_file
  end

  def read_config_file(yaml_dir="config/")
    conf = File.join(Dir.getwd, yaml_dir, self.config_file)
    erb = ERB.new(File.read(conf))
    YAML.load(erb.result binding)
  end
end
