# Log exporter

This docker image allows to forward a service's logs to some external
destination, leveraging the power of [vector][v].

## Configuration

When deploying the log exporter, you must use the [worker Service type](https://www.koyeb.com/docs/reference/services#service-types).

There are 2 mandatory environment variables to be set:
  - `KOYEB_SERVICE` must specify the name of the service whose logs are of
    interest
  - `KOYEB_TOKEN` set with an authentication token, generated as per
    [documentation][a]

Optionally, adding a `DEBUG` environment variable set to any value (`1`, for example),
would enable the log-exporter to dump any log line received to stdout.

### The sinks

This image ships with a preconfigured [source][src] for vector, called `pipe`.
You must reference it in the [sinks][dst] to make them forwarding the logs.

#### Configuration embedded in an environment variable

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

An easy way to achieve the inline format above is using `sed`

```
$ cat <config-file> | sed -z 's/\n/\\n/g'
```

On MacOS, try using `tr`

```
$ cat <config-file> | tr '\n' '\\n'
```

#### Configuration in a (possibly secret) gist or remote file

If you prefer, you can also provide one or more configuration files from remote sources.
The remote sources supported are `gist.github.com` and any remote `HTTP` served file.

You can retrieve a gist specifying its id (the last part of the url), in a variable that
matches the `GIST_*` pattern. All the files in the gist will be pulled and used as
configuration for vector. You can specify more than one gist in differently named
variables.

**Note:** to retrieve the content of a secret gist, one must specify the [variable][ghe]
(`GH_TOKEN`) needed for authentication (the [token][ght] must be a classic one, with the
`gist` permission).

Lastly, one can specify a path to a remote HTTP file in a variable matching the
`REMOTE_FILE_*` pattern and it will be retrieved and used as vector config.

**Note:** the URL must contain the name of the destination file, such that it includes
one of the extensions supported by vector as configuration formats (and of course be in
that format).

[v]: https://vector.dev/
[a]: https://www.koyeb.com/docs/quickstart/koyeb-cli#login
[src]: https://vector.dev/docs/reference/configuration/sources/
[dst]: https://vector.dev/docs/reference/configuration/sinks/
[ghe]: https://cli.github.com/manual/gh_help_environment
[ght]: https://github.com/settings/tokens
