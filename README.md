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

You can retrieve a gist specifying it in the following format

```
/a/local/path:<gist_id_or_url>
```

If specified in a variable whose name follows the pattern `GITS_FILE_*` the gist will be
pulled and it is expected to contain a single file, that will be renamed to
`/a/local/path`. If the path exists and is a directory, the name of the file in the gist
will be preserved and it will be moved into said directory.

> **example**: If the gist contains just a `my.conf` file (assuming the gist id to be
> `1234567890abcdef`):
> ```
> GIST_FILE_MY_CONF=/etc/nginx/conf.d:1234567890abcdef
> ```
> will put `my.conf` in `/etc/nginx/conf.d` (we assume the directory to exist), while
> ```
> GIST_FILE_MY_CONF=/etc/nginx/conf.d/name.conf:1234567890abcdef
> ```
> will put it in `/etc/nginx/conf.d/name.conf`


If specified in a variable whose name follows the pattern `GIST_DIR_*`, all the files in
the gist will be put in `/a/local/path`. If the path exists and is a directory, all the
files in the gist will be moved there in a subdirectory named as the part of the
environment variable that the asterisk expands into. Otherwise, the directory will be created
and all the files will be put there.

> **example**: If the gist contains two files `one.conf` and `two.conf`
> ```
> GIST_DIR_MY_CONF=/etc/nginx/conf.d:1234567890abcdef
> ```
> will put all the files in `/etc/nginx/conf.d/my_conf`.
> ```
> GIST_DIR_MY_CONF=/etc/missing:1234567890abcdef
> ```
> will create `/etc/missing` and place there both the files.

> **NOTE**: On the authentication to github to use secret gists, you can set the `GH_TOKEN` variable.
> See [here][ghe] for more details.

Lastly, one can specify a path to a (publicly available) http file and place it in the
chosen path, specifying the `REMOTE_FILE_*` variable. Note that, in this case, one must
specify the whole path of the destination file.

> **example**: If the remote file is at `https://my.company.tld/config/remote.txt`
> ```
> REMOTE_FILE_MY_CONF=/etc/my.conf:https://my.company.tld/config/remote.txt
> ```
> will place the content located at the given URL in `/etc/my.conf`


[v]: https://vector.dev/
[a]: https://www.koyeb.com/docs/quickstart/koyeb-cli#login
[src]: https://vector.dev/docs/reference/configuration/sources/
[dst]: https://vector.dev/docs/reference/configuration/sinks/
[ghe]: https://cli.github.com/manual/gh_help_environment
