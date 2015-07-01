require_relative "../config"
require 'elasticsearch'

class CloseIndexJob
  @queue = :default

  def self.perform(params)
    es_client = Elasticsearch::Client.new({hosts: [ { host: UPSTREAM_ELASTICSEARCH_HOST, port: UPSTREAM_ELASTICSEARCH_PORT}], trace:false,log:false,transport_options: {request: { timeout: 30000 }}})
    es_client.indices.close index: params['index_name']
  end
end

