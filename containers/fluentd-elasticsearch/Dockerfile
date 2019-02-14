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
RUN BUILD_DEPS="make gcc g++ libc6-dev ruby-dev libffi-dev wget bzip2 gnupg dirmngr zlib1g-dev git" \
    && clean-install $BUILD_DEPS \
                     ca-certificates \
                     libjemalloc1 \
                     ruby \
                     sudo \
                     vim \
                     tar \
                     wget \
    && update-ca-certificates \
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
    && apt-get update \
    && apt-get install supervisor -y \
    && apt-get purge -y --auto-remove \
                     -o APT::AutoRemove::RecommendsImportant=false \
                     $BUILD_DEPS \
    && clean-apt \
    # Ensure fluent has enough file descriptors
    && ulimit -n 65536 \
    && /usr/local/bin/fluentd-ui setup

ENV LD_PRELOAD="/usr/lib/libjemalloc.so.2"

EXPOSE 24224 24220 5170 5140

# Custom Supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY run.sh /run.sh

# Expose prometheus metrics / fluentd ui / out_forward / snmp / in_http / in_udp / in_tcp / in_syslog / promitheus-metrics / monitor-agent
EXPOSE 80 9292 24224 161 9880 5160 5170 5170 5170 24231 24220 5140

ENTRYPOINT ["/run.sh"]

CMD ["supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

# libjemalloc1

# RUN https://github.com/rbspy/rbspy/releases/download/v0.3.3/rbspy-v0.3.3-x86_64-unknown-linux-musl.tar.gz

# RUN curl -sSf https://static.rust-lang.org/rustup.sh | sh

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
