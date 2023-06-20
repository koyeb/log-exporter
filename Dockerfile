FROM koyeb/koyeb-cli:latest AS cli

FROM timberio/vector:latest-distroless-static AS vector

FROM debian:bookworm

RUN apt update \
    && apt install -y s6 ca-certificates \
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
# TODO: copy the startup scripts
# COPY / /etc/s6

# ENTRYPOINT ["/init"]
