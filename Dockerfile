# syntax=docker/dockerfile:1
# Image OliveTin allégée : Alpine + binaire statique OliveTin + webui.
# L'image officielle (Fedora + docker, kubectl, apprise, git, ssh...) fait ~445 Mo.

ARG ALPINE_VERSION=3.24

FROM alpine:${ALPINE_VERSION} AS fetch
ARG OLIVETIN_VERSION
ARG TARGETARCH
ARG TARGETVARIANT
RUN test -n "${OLIVETIN_VERSION}" || (echo "OLIVETIN_VERSION requis" && exit 1)
WORKDIR /dl
RUN set -eux; \
    case "${TARGETARCH}${TARGETVARIANT}" in \
      amd64) ARCH=amd64 ;; arm64) ARCH=arm64 ;; armv7) ARCH=arm7 ;; \
      *) echo "arch non supportée: ${TARGETARCH}${TARGETVARIANT}"; exit 1 ;; \
    esac; \
    BASE="https://github.com/OliveTin/OliveTin/releases/download/${OLIVETIN_VERSION}"; \
    FILE="OliveTin-linux-${ARCH}.tar.gz"; \
    wget -q "${BASE}/${FILE}" "${BASE}/checksums.txt"; \
    grep " ${FILE}\$" checksums.txt | sha256sum -c -; \
    tar xzf "${FILE}"; \
    mkdir -p /out/usr/bin /out/var/www/olivetin; \
    cp "OliveTin-linux-${ARCH}/OliveTin" /out/usr/bin/OliveTin; \
    cp -r "OliveTin-linux-${ARCH}/webui/." /out/var/www/olivetin/; \
    chmod 755 /out/usr/bin/OliveTin

FROM alpine:${ALPINE_VERSION}
ARG OLIVETIN_VERSION
# Paquets supplémentaires éventuels (ex: "docker-cli curl jq")
ARG EXTRA_PACKAGES=""

LABEL org.opencontainers.image.title="OliveTin Lite" \
      org.opencontainers.image.description="Image OliveTin minimale basée sur Alpine" \
      org.opencontainers.image.version="${OLIVETIN_VERSION}" \
      org.opencontainers.image.licenses="AGPL-3.0"

# bash + ssh : scripts shell et actions via SSH ;
# date/seq/tail/touch fournis par busybox.
RUN apk add --no-cache ca-certificates tzdata bash openssh-client-default ${EXTRA_PACKAGES} \
 && adduser -D -u 1000 olivetin \
 && mkdir -p /config \
 && chown olivetin:olivetin /config

COPY --from=fetch /out/ /

USER olivetin
VOLUME /config
EXPOSE 1337/tcp
ENTRYPOINT ["/usr/bin/OliveTin"]

HEALTHCHECK --interval=30s --timeout=5s CMD wget -q -O /dev/null "http://127.0.0.1:${PORT:-1337}/readyz" || exit 1
