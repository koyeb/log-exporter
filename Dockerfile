FROM koyeb/koyeb-cli:latest AS cli

FROM timberio/vector:latest-distroless-static AS vector

FROM debian:bookworm

ARG S6_OVERLAY_VERSION=3.1.5.0

ENV VECTOR_CONFIG_DIR=/etc/vector

RUN apt update \
    && apt install -y ca-certificates xz-utils \
 && rm -rf /var/lib/apt/lists/*

# install s6 init
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp
RUN tar -C / -Jxpf /tmp/s6-overlay-x86_64.tar.xz

# copy the koyeb-cli
COPY --from=cli /koyeb /usr/bin/koyeb

# copy vector and related files
COPY --from=vector /usr/local/bin/vector /usr/bin/vector
COPY --from=vector /etc/vector /etc/vector
COPY --from=vector /var/lib/vector /var/lib/vector
COPY koyeb-source.toml /etc/vector/koyeb-source.toml
COPY sink-console.toml /root
RUN rm /etc/vector/vector.toml

COPY ./s6-overlay /etc/s6-overlay/

ENTRYPOINT ["/init"]
