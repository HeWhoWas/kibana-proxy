# Kibana-Proxy

This is a proof-of-concept proxy server for Kibana. It intercepts requests from the kibana client, inspects the payload
and if it finds an elasticsearch query about to be performed will:

* Open the index
* Wait for the index to become available
* Proxy search query and get results.
* Close the index.
* Return search query data to the client.

As above, it is POC only and probably has a lot of issues.

Relates to https://github.com/elastic/kibana/issues/4308