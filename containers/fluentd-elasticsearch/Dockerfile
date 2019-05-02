# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# This Dockerfile will build an image that is configured
# to run Fluentd with an Elasticsearch plug-in and the
# provided configuration file.
# The image acts as an executable for the binary /usr/sbin/td-agent.
# Note that fluentd is run with root permssion to allow access to
# log files with root only access under /var/log/containers/*

# FROM debian:stretch-slim
FROM k8s.gcr.io/fluentd-elasticsearch:v2.2.0

ENV RBSPY_RELEASE="https://github.com/rbspy/rbspy/releases/download/v0.3.3/rbspy-v0.3.3-x86_64-unknown-linux-musl.tar.gz" \
    RUBY_GC_HEAP_OLDOBJECT_LIMIT_FACTOR="1.2" \
    GOSU_VERSION=1.10 \
    JEMALLOC_VERSION=4.5.0

# RUN apt-get install -y sudo vim tar wget \
#     && clean-apt && \
#     wget -O /tmp/rbspy.tar.gz "${RBSPY_RELEASE}" \
#     && mkdir -p /opt/rbspy \
#     && tar -xvzf /tmp/rbspy.tar.gz -C /opt/rbspy

# s6-overlay-amd64.tar.gz - includes binaries for 64-bit Intel/AMD platforms
# s6-overlay-x86.tar.gz - includes binaries for 32-bit Intel/AMD platforms
# s6-overlay-armhf.tar.gz - includes binaries for 32-bit ARM (hard-float) platforms, ie, Raspberry Pi
# s6-overlay-arm.tar.gz - includes binaries for 32-bit ARM platforms
# s6-overlay-aarch64.tar.gz - includes binaries for 64-bit ARM platforms.



###############################################################
#  ..######...#######...........#######..##.....##.########.########..##..........###....##....##
#  .##....##.##.....##.........##.....##.##.....##.##.......##.....##.##.........##.##....##..##.
#  .##.......##................##.....##.##.....##.##.......##.....##.##........##...##....####..
#  ..######..########..#######.##.....##.##.....##.######...########..##.......##.....##....##...
#  .......##.##.....##.........##.....##..##...##..##.......##...##...##.......#########....##...
#  .##....##.##.....##.........##.....##...##.##...##.......##....##..##.......##.....##....##...
#  ..######...#######...........#######.....###....########.##.....##.########.##.....##....##...
###############################################################
# SOURCE: https://github.com/christiansteier/moodle-docker/blob/591b24642dc5c0988b5512746ecffd45f19f24d5/apache/Dockerfile
# ARG minimal_apt_get_install='apt-get install -y --no-install-recommends'
# ENV DEBIAN_FRONTEND=noninteractive \
#     DEBCONF_NONINTERACTIVE_SEEN=true
# RUN /scripts/prepare.sh && \
#     \
#     # System services \
#     echo "\n[i] Install s6-overlay\n" && \
#     $minimal_apt_get_install curl gnupg && \
#     GPG="DB30 1BA3 F6F8 07E0 D0E6  CCB8 6101 B278 3B2F D161" && \
#     S6OVERLAY=$(curl -s https://api.github.com/repos/just-containers/s6-overlay/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")') && \
#     if [ $(uname -m) = "armv6l" ] || [ $(uname -m) = "armv7l" ]; then ARCHTAG=armhf ; elif [ $(uname -m) = "aarch64" ]; then ARCHTAG=aarch64 ; elif [ $(uname -m) = "x86_64" ]; then ARCHTAG=amd64 ; fi && \
#     curl -o /tmp/s6-overlay.tar.gz -L https://github.com/just-containers/s6-overlay/releases/download/${S6OVERLAY}/s6-overlay-${ARCHTAG}.tar.gz && \
#     curl -o /tmp/s6-overlay.tar.gz.sig -L https://github.com/just-containers/s6-overlay/releases/download/${S6OVERLAY}/s6-overlay-${ARCHTAG}.tar.gz.sig && \
#     curl https://keybase.io/justcontainers/key.asc | gpg --import && \
#     FINGERPRINT="$(LANG=C gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz 2>&1 | sed -n "s#Primary key fingerprint: \(.*\)#\1#p")" && \
#     gpg --verify /tmp/s6-overlay.tar.gz.sig /tmp/s6-overlay.tar.gz && \
#     if [ -z "${FINGERPRINT}" ]; then echo "[!!] Invalid GPG signature!" && exit 1; fi && \
#     if [ "${FINGERPRINT}" != "${GPG}" ]; then echo "[!!] Wrong GPG fingerprint!" && exit 1; fi && \
#     echo "[i] All seems good, now unpacking s6-overlay.tar.gz" && \
#     tar xzf /tmp/s6-overlay.tar.gz -C / && \
#     \
#     echo -e "\n[i] Install socklog-overlay\n" && \
#     SOCKLOG=$(curl -s https://api.github.com/repos/just-containers/socklog-overlay/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")') && \
#     curl -o /tmp/socklog-overlay-amd64.tar.gz -L https://github.com/just-containers/socklog-overlay/releases/download/${SOCKLOG}/socklog-overlay-${ARCHTAG}.tar.gz && \
#     tar xzf /tmp/socklog-overlay-amd64.tar.gz -C / && \
#     \
#     echo -e "\n[i] Install cron\n" && \
#     $minimal_apt_get_install cron && \
#     \
#     # Utilities \
#     echo -e "\n[i] Install often used tools\n" && \
#     $minimal_apt_get_install bzip2 vim-tiny curl git-core rsync unzip graphviz && \
#     ln -s /usr/bin/vim.tiny /usr/bin/vim && \
#     \
#     # Cleanup \
#     apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false bzip2 vim-tiny git-core && \
#     apt-get clean
#     # \
#     # && \
#     # rm -rf /var/lib/apt/lists/* /etc/dpkg/dpkg.cfg.d/02apt-speedup /etc/ssh/ssh_host_* /var/cache/ldconfig/aux-cache /usr/share/doc /usr/share/man/ /usr/share/info/* /var/cache/man/* /tmp/* /etc/fstab /scripts

# set -eux; \
#     dpkgArch="$(dpkg --print-architecture)"; \
#     case "${dpkgArch##*-}" in \
#         amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='2d4ddf4e53915a23dda722608ed24e5c3f29ea1688da55aa4e98765fc6223f71' ;; \
#         armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='be85f50dc70ee239c5bb6acb60080797841a1e7c45fbf6bae15d6bd4b37ce0e5' ;; \
#         arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='454f00a86be75ab070149bac1f541a7b39e5d3383d6da96ad2b929867ed40167' ;; \
#         i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='179e3b39f11037a708874e750081f7c0d3e1a6a4c431c2ecee2295acc7b696af' ;; \
#         *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
#     esac; \
#     url="https://static.rust-lang.org/rustup/archive/1.16.0/${rustArch}/rustup-init"; \
#     wget "$url"; \
#     echo "${rustupSha256} *rustup-init" | sha256sum -c -; \

ARG DEBIAN_FRONTEND=noninteractive

# COPY clean-apt /usr/bin
# COPY clean-install /usr/bin
COPY Gemfile /Gemfile

# SOURCE: https://docs.fluentd.org/v1.0/articles/before-install
# net.core.somaxconn = 1024
# net.core.netdev_max_backlog = 5000
# net.core.rmem_max = 16777216
# net.core.wmem_max = 16777216
# net.ipv4.tcp_wmem = 4096 12582912 16777216
# net.ipv4.tcp_rmem = 4096 12582912 16777216
# net.ipv4.tcp_max_syn_backlog = 8096
# net.ipv4.tcp_slow_start_after_idle = 0
# net.ipv4.tcp_tw_reuse = 1
# net.ipv4.ip_local_port_range = 10240 65535

# && curl -L https://toolbelt.treasuredata.com/sh/install-debian-stretch-td-agent3.sh | sh && \

# RUN set -ex && \
#     \
#     groupadd -r elasticsearch && useradd -r -m -g elasticsearch elasticsearch && \
#     groupadd -r kibana && useradd -r -m -g kibana kibana && \
#     apt-get update && \
#     apt-get install -y curl locales && locale-gen en_US.UTF-8 && \
#     apt-get install -y wget supervisor openjdk-8-jre unzip

# 1. Install & configure dependencies.
# 2. Install fluentd via ruby.
# 3. Remove build dependencies.
# 4. Cleanup leftover caches & files.
RUN set -x; BUILD_DEPS="make gcc g++ libc6-dev ruby-dev libffi-dev wget bzip2 gnupg dirmngr zlib1g-dev git" \
    && clean-install $BUILD_DEPS \
                     ca-certificates \
                     libjemalloc1 \
                     ruby \
                     sudo \
                     vim \
                     tar \
                     wget \
    && update-ca-certificates \
    && apt-get update \
    && apt-get install -y build-essential \
    && apt-get install -y autogen autoconf libtool libgeoip-dev gzip wget \
    && dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$dpkgArch.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && rm -rf "$GNUPGHOME" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true \
    && wget -O /tmp/jemalloc-$JEMALLOC_VERSION.tar.bz2 https://github.com/jemalloc/jemalloc/releases/download/$JEMALLOC_VERSION/jemalloc-$JEMALLOC_VERSION.tar.bz2 && cd /tmp \
    && tar -xjf jemalloc-$JEMALLOC_VERSION.tar.bz2 \
    && cd jemalloc-$JEMALLOC_VERSION/ \
    && ./configure \
    && make \
    && mv lib/libjemalloc.so.2 /usr/lib \
    && echo 'gem: --no-document' >> /etc/gemrc \
    && gem install --file /Gemfile \
    && apt-get purge -y --auto-remove \
                     -o APT::AutoRemove::RecommendsImportant=false \
                     $BUILD_DEPS \
    && clean-apt \
    # Ensure fluent has enough file descriptors
    && ulimit -n 65536

RUN apt-get update \
    && apt-get install supervisor net-tools procps tree tcpdump netcat bash-completion htop wget gzip -y \
    && clean-apt

# SOURCE: https://dev.maxmind.com/geoip/geoip2/geolite2/
RUN set -x; mkdir -p /geoip && \
    cd /geoip && \
    wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz && \
    wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.tar.gz && \
    wget https://geolite.maxmind.com/download/geoip/database/GeoLite2-ASN.tar.gz && \
    gunzip GeoLite2-City.tar.gz && \
    gunzip GeoLite2-Country.tar.gz && \
    gunzip GeoLite2-ASN.tar.gz && \
    tar -xvf GeoLite2-City.tar && \
    tar -xvf GeoLite2-Country.tar && \
    tar -xvf GeoLite2-ASN.tar && \
    mv -v GeoLite2-*/*.mmdb . && \
    rm -rfv GeoLite2-{ASN,City,Country}_* && \
    rm -rfv *.tar && \
    rm -rfv *.tar.gz

ENV LD_PRELOAD="/usr/lib/libjemalloc.so.2"

# EXPOSE 24224 24220 5170 5140

# Custom Supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY supervisord-main.conf /etc/supervisor/supervisord.conf
COPY supervisord.logrotate /etc/logrotate.d/supervisord
COPY fluentd-run /usr/local/bin/fluentd-ui-run
COPY fluentd-ui-run /usr/local/bin/fluentd-ui-run
COPY run.sh /run.sh

# Expose prometheus metrics / fluentd ui / out_forward / snmp / in_http / in_udp / in_tcp / in_syslog / promitheus-metrics / monitor-agent
EXPOSE 80 9292 24224 161 9880 5160 5170 24231 24220 5140

# ORIG: # Expose prometheus metrics / fluentd ui / out_forward / snmp / in_http / in_udp / in_tcp / in_syslog / promitheus-metrics / monitor-agent
# EXPOSE 80 9292 24224 161 9880 5160 5170 5170 5170 24231 24220

# forward request and error logs to docker log collector
# RUN mkdir -p /var/log/supervisor \
#     && touch /var/log/supervisor/supervisord.log \
#     && ln -sf /dev/stdout /var/log/supervisor/supervisord.log
RUN mkdir -p /opt/supervisor/log/supervisor/ && \
    mkdir -p /opt/supervisor/run/

# ENTRYPOINT ["/run.sh"]
CMD ["/run.sh"]

# CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

# libjemalloc1

# RUN https://github.com/rbspy/rbspy/releases/download/v0.3.3/rbspy-v0.3.3-x86_64-unknown-linux-musl.tar.gz

# RUN curl -sSf https://static.rust-lang.org/rustup.sh | sh

# NOTE: Install rust
# ENV RUSTUP_HOME=/usr/local/rustup \
#     CARGO_HOME=/usr/local/cargo \
#     PATH=/usr/local/cargo/bin:$PATH \
#     RUST_VERSION=1.32.0

# RUN set -eux; \
#     dpkgArch="$(dpkg --print-architecture)"; \
#     case "${dpkgArch##*-}" in \
#         amd64) rustArch='x86_64-unknown-linux-gnu'; rustupSha256='2d4ddf4e53915a23dda722608ed24e5c3f29ea1688da55aa4e98765fc6223f71' ;; \
#         armhf) rustArch='armv7-unknown-linux-gnueabihf'; rustupSha256='be85f50dc70ee239c5bb6acb60080797841a1e7c45fbf6bae15d6bd4b37ce0e5' ;; \
#         arm64) rustArch='aarch64-unknown-linux-gnu'; rustupSha256='454f00a86be75ab070149bac1f541a7b39e5d3383d6da96ad2b929867ed40167' ;; \
#         i386) rustArch='i686-unknown-linux-gnu'; rustupSha256='179e3b39f11037a708874e750081f7c0d3e1a6a4c431c2ecee2295acc7b696af' ;; \
#         *) echo >&2 "unsupported architecture: ${dpkgArch}"; exit 1 ;; \
#     esac; \
#     url="https://static.rust-lang.org/rustup/archive/1.16.0/${rustArch}/rustup-init"; \
#     wget "$url"; \
#     echo "${rustupSha256} *rustup-init" | sha256sum -c -; \
#     chmod +x rustup-init; \
#     ./rustup-init -y --no-modify-path --default-toolchain $RUST_VERSION; \
#     rm rustup-init; \
#     chmod -R a+w $RUSTUP_HOME $CARGO_HOME; \
#     rustup --version; \
#     cargo --version; \
#     rustc --version;

# git clone https://github.com/rbspy/rbspy
# cd rbspy
# cargo install

# Ballerina runtime distribution filename.
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bossjones/kibana"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="TonyDark Industries"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL maintainer="jarvis@theblacktonystark.com"
