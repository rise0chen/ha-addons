FROM ubuntu:20.04

# Build runtime environment
RUN apt-get update
RUN apt-get install -yq sudo bash wget git-core
RUN apt-get install -yq iptables iproute2 jq
RUN ln -sf /sbin/iptables-nft /sbin/iptables
RUN ln -sf /sbin/iptables-nft-save /sbin/iptables-save
RUN ln -sf /sbin/iptables-nft-restore /sbin/iptables-restore

# Set workspace
WORKDIR /clash
ARG TARGETARCH
ENV CONFIG_PATH="/data/options.json"

# Install clash tool
ENV SUBCONVERTER_VERSION=0.9.0
RUN case "${TARGETARCH}" in \
        "amd64") ARCH="linux64" ;; \
        "arm64") ARCH="aarch64" ;; \
        *) echo "不支援的架構: ${TARGETARCH}"; exit 1 ;; \
    esac && \
    wget "https://github.com/tindy2013/subconverter/releases/download/v${SUBCONVERTER_VERSION}/subconverter_${ARCH}.tar.gz" -O subconverter.tar.gz
RUN tar -xzf subconverter.tar.gz && rm -f subconverter.tar.gz

# Install clash UI
RUN git clone -b gh-pages https://github.com/ayanamist/clash-dashboard config/ui

# Install clash
ENV CLASH_VERSION=1.19.25
RUN wget https://github.com/MetaCubeX/mihomo/releases/download/v${CLASH_VERSION}/mihomo-linux-${TARGETARCH}-v${CLASH_VERSION}.gz
RUN gzip -d mihomo-linux-${TARGETARCH}-v${CLASH_VERSION}.gz
RUN chmod 755 mihomo-linux-${TARGETARCH}-v${CLASH_VERSION}
RUN mv mihomo-linux-${TARGETARCH}-v${CLASH_VERSION} /usr/local/bin/clash

# Install yq
RUN wget https://github.com/mikefarah/yq/releases/download/v4.53.2/yq_linux_${TARGETARCH}
RUN chmod 755 yq_linux_${TARGETARCH}
RUN mv yq_linux_${TARGETARCH} /usr/local/bin/yq

# Build app
COPY config /clash/config
COPY scripts /clash/scripts
RUN chmod 755 /clash/scripts/*

# Proxy
EXPOSE 7890
EXPOSE 7891
# UI
EXPOSE 9090
# Router
EXPOSE 7893
EXPOSE 53

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT ["bash", "/entrypoint.sh"]
