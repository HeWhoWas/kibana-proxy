require 'elasticsearch'

configure do
  @@es_client = Elasticsearch::Client.new({hosts: [ { host: UPSTREAM_ELASTICSEARCH_HOST, port: UPSTREAM_ELASTICSEARCH_PORT}], trace:false,log:false,transport_options: {request: { timeout: 30000 }}})
end

def is_elasticsearch_request?(req_path)
  req_path =~ /.elasticsearch.*/
end

def is_index_closed?(index_name)
  if(@@es_client.indices.exists(index: index_name))
    begin
      @@es_client.indices.stats index: index_name
      return false
    rescue Elasticsearch::Transport::Transport::Errors::Forbidden => e
      return true
    end
  end
end

def open_index(index_name)
  @@es_client.indices.open index: index_name
  @@es_client.cluster.health wait_for_status: 'yellow'
end

def close_index(index_name)
  @@es_client.indices.close index: index_name
end

def parse_elasticsearch_index(req_path, req_body)
  index = nil

  if req_body.include?("\n") #Kibana can send multiple JSON requests in the same body.
    json_parts = req_body.split("\n")
  else
    json_parts = []
    json_parts << req_body
  end

  json_parts.each do | json_part |
    params = JSON.parse(json_part)
    if params["docs"] && params["docs"][0] && params["docs"][0]["_index"]
      return params["docs"][0]["_index"]
    elsif params["index"]
      return params["index"]
    end
  end
  if index.nil?
    if req_path.include?("/elasticsearch/")
      captures = /.*\/elasticsearch\/(.+?)\//.match(req_path).captures
      if captures.length > 0
        return captures[0]
      end
    end
  end
end