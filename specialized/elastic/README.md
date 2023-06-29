# Log exporter image for Elasticsearch

This image is designed to allow the forwarding of logs from [koyeb][k]
services to an Elasticsearch instance. Currently, only the basic
authentication scheme is supported.

For more details, see the vector sink [documentation][d]

The following environment variables are needed to configure it:
  - `ELASTICSEARCH_USER`: the user to authenticate with
  - `ELASTICSEARCH_PASSWORD`: the password to authenticate with (use a koyeb secret!)
  - `ELASTICSEARCH_ENDPOINT`: the HTTPS URI where the Elasticsearch instance accepts incoming messages

[k]: https://www.koyeb.com/
[d]: https://vector.dev/docs/reference/configuration/sinks/elasticsearch/
