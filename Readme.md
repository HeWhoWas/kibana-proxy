 # Kibana-Proxy

This is a proof-of-concept proxy server for Kibana. It intercepts requests from the kibana client, inspects the payload
and if it finds an elasticsearch query about to be performed will:

* Open the index
* Wait for the index to become available
* Proxy search query and get results.
* Close the index.
* Return search query data to the client.

As above, it is POC only and probably has a lot of issues.

## Configuration

You need to update the values held in config.rb:

* UPSTREAM_KIBANA_HOST = The kibana server IP or hostname.
* UPSTREAM_ELASTICSEARCH_HOST = The elasticsearch server kibana normally talks to.
* UPSTREAM_ELASTICSEARCH_PORT = The port too connecto to elasticsearch over.

## Running

The following will run kibana-proxy on 0.0.0.0:80

 cd kibana-proxy
 rackup -p 80 --host 0.0.0.0

Relates to https://github.com/elastic/kibana/issues/4308