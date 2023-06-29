# Log exporter image for Splunk

This image is designed to allow the forwarding of logs from [koyeb][k]
services to a Splunk instance.

For more details, see the vector sink [documentation][d]

The following environment variables are needed to configure it:
  - `ENCODING_CODEC`: defaults to `json`, but could be changed to a [supported value][s] (except `avro` and `csv`)
  - `SPLUNK_TOKEN`: the token to authenticate to Splunk with
  - `SPLUNK_ENDPOINT`: the URI where the Splunk instance accepts the logs
  - `SPLUNK_INDEX`: the index in Splunk to use to save the logs
  - `SPLUNK_SOURCE_TYPE`: the source type to use for these logs, defaults to `koyeblogs`

[k]: https://www.koyeb.com/
[d]: https://vector.dev/docs/reference/configuration/sinks/splunk_hec_logs/
[s]: https://vector.dev/docs/reference/configuration/sinks/splunk_hec_logs/#encoding.codec
