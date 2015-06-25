require 'sinatra'
require 'net/http'
require 'json'
require_relative('config')

class KibanaProxy < Sinatra::Base
  helpers do
    def request_headers
      @request.env.inject({}){|acc, (k,v)| acc[$1.downcase] = v if k =~ /^http_(.*)/i; acc}
    end
  end

  proxy = lambda do |path|
    uri = URI('http://' + UPSTREAM_KIBANA_HOST + "/" + path)
    uri.query = URI.encode_www_form(params) if (request.request_method == 'GET')

    # New request data
    data = {
        :url => 'http://' + uri.host + ':' + uri.port.to_s + uri.request_uri,
        :method => @request.request_method,
        :headers => request_headers,
        :query => uri.query
    }

    http = Net::HTTP.new(uri.host, uri.port)
    index_opened = false

    if @request.request_method == 'POST'
      req = Net::HTTP::Post.new uri.request_uri
      @request.body.rewind
      body = @request.body.read

      if is_elasticsearch_request?(uri.request_uri)
        index = parse_elasticsearch_index(uri.request_uri, body)
        if index.nil?
          puts "Unable to identify elasticsearch index for request"
        elsif (index != ".kibana4") && (is_index_closed?(index))
          open_index(index)
          index_opened = true
        end
      end

      req.body = body
      req.delete("content-type")
    else
      req = Net::HTTP::Get.new uri.request_uri
    end

    # Passthrough headers
    data[:headers]['host'] = uri.host + ':' + uri.port.to_s
    data[:headers].each { |key, val| req[key] = val }
    # Log request data
    res = http.request req

    if index_opened && ! index.nil?
      close_index(index)
    end

    # Return
    status res.code
    content_type res.header['content-type']
    headers res.to_hash
    body res.body
  end

  require_relative('lib/elasticsearch')

  get '/*', &proxy
  post '/*', &proxy
end

