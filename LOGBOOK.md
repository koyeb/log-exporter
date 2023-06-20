# Logbook

### First hackish attempt: use anonymous pipe

Just verify locally that we can pipe the output of the koyeb cli to vector via
stdin, using the following configuration

```toml
# Input from stdin
[sources.pipe]
type = "stdin"
decoding.codec = "json"

# Print parsed logs to stdout
[sinks.print]
type = "console"
inputs = ["pipe"]
encoding.codec = "json"
```

Run on the local shell

```
$ koyeb services logs <SERVICE_NAME> | sudo -u vector vector -c ./vector.toml
```

### Second attempt: named pipe

Create a named pipe

```
$ mkfifo /tmp/vector-koyeb
```

In a terminal, redirect the named pipe to `vector`'s stdin

```
$ cat /tmp/vector-koyeb | sudo -u vector vector -c ./vector.toml
```

In a second terminal, pipe the output of the cli to the named pipe

```
$ koyeb services logs <SERVICE_NAME> | tee /tmp/vector-koyeb
```

**NOTE**: `vector` exits if the second process (writing into the pipe) exits.

### Third attempt: docker container

We want to packetize this. We can use the following `Dockerfile`

```Dockerfile
FROM koyeb/koyeb-cli:latest AS cli

FROM timberio/vector:latest-distroless-static AS vector

FROM debian:bookworm

RUN apt update \
    && apt install -y ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# copy the koyeb-cli
COPY --from=cli /koyeb /usr/bin/koyeb

# copy vector and related files
COPY --from=vector /usr/local/bin/vector /usr/bin/vector
COPY --from=vector /etc/vector /etc/vector
COPY --from=vector /var/lib/vector /var/lib/vector
COPY vector.toml /etc/vector/vector.toml

COPY entrypoint.sh /

ENTRYPOINT ["/entrypoint.sh"]
```

`entrypoint.sh` being

```bash
#!/usr/bin/bash

set -eo pipefail

PIPE=/tmp/vector-koyeb

if [ -z $KOYEB_SERVICE ]; then
    echo "KOYEB_SERVICE must be set"
    exit 1
fi

if [ -z $KOYEB_TOKEN ]; then
    echo "KOYEB_TOKEN must be set"
    exit 1
fi

mkfifo "${PIPE}"

(cat "${PIPE}"|vector) &
koyeb \
    --token "${KOYEB_TOKEN}" \
    --url "${KOYEB_URL:-https://app.koyeb.com}" \
    services logs ${KOYEB_SERVICE} >> "${PIPE}"
```

After we built it with `docker build -t koyeb/vector` we can start it with (testing in
staging)

```
docker run --rm \
    -e KOYEB_SERVICE=<KOYEB_SERVICE> \
    -e KOYEB_TOKEN=<KOYEB_TOKEN> \
    -e KOYEB_URL="https://staging.koyeb.com" \
    -ti koyeb/vector
```
