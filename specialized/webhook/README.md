# Log exporter image for Webhooks

This image is designed to allow the forwarding of logs from [koyeb][k]
services to a webhook receiving endpoint. Currently, only `Bearer` based
authentication is supported.

For more details, see the vector sink [documentation][d]

The following environment variables are needed to configure it:
  - `ENCODING_CODEC`: defaults to `json`, but could be changed to a [supported value][s] (except `avro` and `csv`)
  - `WEBHOOK_URI`: the URI where the webhook accepts the logs
  - `WEBHOOK_TOKEN`: the token used to authenticate towards the webhook server

[k]: https://www.koyeb.com/
[d]: https://vector.dev/docs/reference/configuration/sinks/http/
[s]: https://vector.dev/docs/reference/configuration/sinks/http/#encoding.codec
