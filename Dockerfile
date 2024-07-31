ARG KOYEB_CLI_VERSION

FROM koyeb/koyeb-cli:$KOYEB_CLI_VERSION AS cli

LABEL com.koyeb.cli-version=${KOYEB_CLI_VERSION}

FROM timberio/vector:latest-distroless-static AS vector

FROM debian:bookworm

ARG S6_OVERLAY_VERSION=3.2.0.0

LABEL com.koyeb.s6-version=${S6_OVERLAY_VERSION}}

ENV VECTOR_CONFIG_DIR=/etc/vector

RUN apt update \
    && apt install -y \
        ca-certificates \
        xz-utils \
        git \
        gh \
        curl \
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
RUN rm /etc/vector/vector.*

COPY ./s6-overlay /etc/s6-overlay/

ENTRYPOINT ["/init"]
