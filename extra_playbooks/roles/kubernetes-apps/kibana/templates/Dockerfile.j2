FROM docker.elastic.co/kibana/kibana:5.6.2
MAINTAINER TonyDark Jarvis <jarvis@theblacktonystark.com>

USER root

# rlimit/ulimit support - https://github.com/kubernetes/kubernetes/issues/3595

# Legend
# -Xms = -XX:InitialHeapSize
# -Xmx = -XX:MaxHeapSize)
# -Xmx2g -Xms2g
ENV \
LANG=C.UTF-8 \
KIBANA_HOME="/usr/share/kibana" \
KIBANA_USER_ID="65534" \
KIBANA_GROUP_ID="65534" \
VULNWHISPERER_RELEASE="https://github.com/HASecuritySolutions/VulnWhisperer/archive/1.7.1.tar.gz"

# # Kubernetes requires swap is turned off, so memory lock is redundant
# ENV MEMORY_LOCK false
# nobody:x:99:

RUN groupmod -g ${KIBANA_USER_ID} kibana
RUN usermod -u ${KIBANA_USER_ID} -g ${KIBANA_GROUP_ID} kibana
RUN chown -Rv kibana:kibana ${KIBANA_HOME}

RUN yum install sudo vim wget tar tree zlib-devel libxml2-devel libxslt-devel -y; yum clean all; yum clean metadata

# Use tini as subreaper in Docker container to adopt zombie processes
# ARG TINI_VERSION=v0.16.1
# COPY tini_pub.gpg ${KIBANA_HOME}/tini_pub.gpg
# RUN curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture) -o /sbin/tini \
#   && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture).asc -o /sbin/tini.asc \
#   && gpg --no-tty --import ${KIBANA_HOME}/tini_pub.gpg \
#   && gpg --verify /sbin/tini.asc \
#   && rm -rf /sbin/tini.asc /root/.gnupg \
#   && chmod +x /sbin/tini

# EXPOSE 1099

# vulnwhisperer

# FIXME: This needs to go into logstash Install vulnwhisperer
# RUN wget -O /tmp/vulnwhisperer.gz "${VULNWHISPERER_RELEASE}" \
#     && mkdir -p /opt/vulnwhisperer \
#     && tar -xvzf /tmp/vulnwhisperer.gz -C /opt/vulnwhisperer

# Add your kibana plugins setup here
# Example: RUN kibana-plugin install <name|url>

COPY --chown=kibana:kibana ./config ./config
COPY --chown=kibana:kibana ./bin ./bin
COPY --chown=kibana:kibana ./local_plugins ./local_plugins

# kibana-plugin remove x-pack && \

RUN kibana-plugin install file:///usr/share/kibana/local_plugins/logtrail-5.6.2-0.1.21.zip \
    kibana-plugin install https://github.com/sirensolutions/sentinl/releases/download/tag-5.6.2/sentinl-v5.6.2.zip \
    kibana-plugin install https://github.com/datasweet/kibana-datasweet-formula/releases/download/v1.1.2/datasweet_formula-1.1.2_kibana-5.6.2.zip

# FIXME: Requires ES - 6.5.4
# env NODE_OPTIONS="--max-old-space-size=3072" kibana-plugin install https://packages.wazuh.com/wazuhapp/wazuhapp-3.7.2_6.5.4.zip

# RUN kibana-plugin install file:///usr/share/kibana/local_plugins/logtrail-5.6.2-0.1.21.zip

RUN set -eux; \
    curl -L 'https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64' > /usr/local/bin/gosu && \
	chmod +x /usr/local/bin/gosu
# # verify that the binary works
# 	gosu kibana true

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
