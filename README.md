# Log exporter

This docker image allows to forward a service's logs to some external
destination, leveraging the power of [vector][v].

## Configuration

There are 2 mandatory environment variables to be set:
  - `KOYEB_SERVICE` must specify the name of the service whose logs are of
    interest
  - `KOYEB_TOKEN` set with an authentication token, generated as per
    [documentation][a]

### The sinks

This image ships with a preconfigured [source][src] for vector, called `pipe`.
You must reference it in the [sinks][dst] to make them forwarding the logs.

To specify the [sinks][dst] configuration, you must pass the configuration as an inline version of the configuration section.
For example, if want to forward the logs to an HTTP destination, your configuration would be like this

```toml
[sinks.hook]
type = "http"
inputs = ["pipe"]
encoding.codec = "json"
uri = "https://my.endpoint.org/logs"
method = "post"
```

You must replace every new line with `\n` and assign it to an environment
variable of the form `SINK_TOML_*`. For example

```
SINK_TOML_HTTP='[sinks.hook]\ntype = "http"\ninputs = ["pipe"]\nencoding.codec = "json"\nuri = "https://my.endpoint.org/logs"\nmethod = "post"\n'
```

The same holds for yaml (`SINK_YAML_*`) and json (`SINK_JSON_*`) configuration
formats.

You can specify as many sinks as you please.

An easy way to achieve the inline format above is using sed

```
$ cat <config-file> | sed -z 's/\n/\\n/g'
```

On MacOS, try using `tr`

```
$ cat <config-file> | tr '\n' '\\n'
```

[v]: https://vector.dev/
[a]: https://www.koyeb.com/docs/quickstart/koyeb-cli#login
[src]: https://vector.dev/docs/reference/configuration/sources/
[dst]: https://vector.dev/docs/reference/configuration/sinks/
