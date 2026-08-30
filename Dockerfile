FROM jlesage/baseimage-gui:ubuntu-24.04-v4

ARG FLCLASH_VERSION
ARG TARGETARCH

ENV FLCLASH_VERSION=${FLCLASH_VERSION}
ENV APP_NAME=flclash
ENV APP_RUN=/startapp.sh

# INSTALL DEPENDENCIES
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      socat \
      locales \
      dbus \
      libayatana-appindicator3-dev \
      libkeybinder-3.0-dev \
      curl \
      wget \
      jq \
      ca-certificates \
      fonts-noto-cjk \
      fonts-wqy-zenhei \
      fonts-wqy-microhei && \
    locale-gen zh_CN.UTF-8 en_US.UTF-8 && \
    update-locale LANG=zh_CN.UTF-8 && \
    rm -rf /var/lib/apt/lists/*

ENV LANG=zh_CN.UTF-8
ENV LC_ALL=zh_CN.UTF-8

# Download the FlClash package for the target architecture and verify its checksum
RUN set -ex; \
    VERSION="${FLCLASH_VERSION#v}"; \
    DEB_NAME="FlClash-${VERSION}-linux-${TARGETARCH}.deb"; \
    echo "Downloading ${DEB_NAME} (${FLCLASH_VERSION})"; \
    curl -fsSL -o "/tmp/${DEB_NAME}" \
      "https://github.com/chen08209/FlClash/releases/download/${FLCLASH_VERSION}/${DEB_NAME}"; \
    curl -fsSL -o /tmp/SHA256SUMS \
      "https://github.com/chen08209/FlClash/releases/download/${FLCLASH_VERSION}/SHA256SUMS"; \
    (cd /tmp && grep "${DEB_NAME}" SHA256SUMS | sha256sum -c -); \
    apt-get update && \
    apt-get install -y "/tmp/${DEB_NAME}" || apt-get install -fy; \
    rm -f "/tmp/${DEB_NAME}" /tmp/SHA256SUMS; \
    rm -rf /var/lib/apt/lists/*

# Create start-up script: forward Clash controller (127.0.0.1:9090) to 9091
RUN echo '#!/bin/sh\n\
socat TCP-LISTEN:9091,fork,reuseaddr TCP:127.0.0.1:9090 &\n\
exec FlClash' > /startapp.sh && chmod +x /startapp.sh

# Expose GUI, proxies and DNS ports
EXPOSE 5800 5900 7890/tcp 7891/tcp 1053/udp 9091/tcp
