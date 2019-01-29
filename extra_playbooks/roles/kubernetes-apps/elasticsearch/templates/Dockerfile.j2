FROM k8s.gcr.io/elasticsearch:v5.6.2
MAINTAINER TonyDark Jarvis <jarvis@theblacktonystark.com>

# rlimit/ulimit support - https://github.com/kubernetes/kubernetes/issues/3595

# Legend
# -Xms = -XX:InitialHeapSize
# -Xmx = -XX:MaxHeapSize)
# -Xmx2g -Xms2g
ENV \
LANG=C.UTF-8 \
JVMTOP_RELEASE="https://github.com/patric-r/jvmtop/releases/download/0.8.0/jvmtop-0.8.0.tar.gz" \
ELASTICSEARCH_HOME="/usr/share/elasticsearch" \
DEFAULT_ES_JAVA_INITIAL_HEAP_SIZE="-Xms2g" \
DEFAULT_ES_JAVA_MAX_HEAP_SIZE="-Xmx2g" \
ELASTICSEARCH_USER_ID="65534" \
ELASTICSEARCH_GROUP_ID="65534" \
MEMORY_LOCK=false

# # Kubernetes requires swap is turned off, so memory lock is redundant
# ENV MEMORY_LOCK false
# nobody:x:99:

RUN groupmod -g ${ELASTICSEARCH_USER_ID} elasticsearch
RUN usermod -u ${ELASTICSEARCH_USER_ID} -g ${ELASTICSEARCH_GROUP_ID} elasticsearch
RUN chown -Rv elasticsearch:elasticsearch ${ELASTICSEARCH_HOME}
# RUN sed -i -e 's/--userspec=1000/--userspec=${ELASTICSEARCH_USER_ID}/g' \
#            -e 's/UID 1000/UID ${ELASTICSEARCH_USER_ID}/' \
#            -e 's/chown -R 1000/chown -R ${ELASTICSEARCH_USER_ID}/' /usr/local/bin/docker-entrypoint.sh
# RUN chown elasticsearch /usr/local/bin/docker-entrypoint.sh

# # Kubernetes requires swap is turned off, so memory lock is redundant
# ENV MEMORY_LOCK false

# https://github.com/pires/docker-elasticsearch-kubernetes/blob/master/config/elasticsearch.yml
# bootstrap:
#     memory_lock: ${MEMORY_LOCK}

RUN yum install sudo vim wget tar tree -y; yum clean all; yum clean metadata

# Install jvmtop
RUN wget -O /tmp/jvmtop.gz "${JVMTOP_RELEASE}" \
    && mkdir -p /opt/jvmtop \
    && tar -xvzf /tmp/jvmtop.gz -C /opt/jvmtop \
    && chmod +x /opt/jvmtop/jvmtop.sh \
    && rm /tmp/jvmtop.gz

# Use tini as subreaper in Docker container to adopt zombie processes
# ARG TINI_VERSION=v0.16.1
# COPY tini_pub.gpg ${ELASTICSEARCH_HOME}/tini_pub.gpg
# RUN curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture) -o /sbin/tini \
#   && curl -fsSL https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-$(dpkg --print-architecture).asc -o /sbin/tini.asc \
#   && gpg --no-tty --import ${ELASTICSEARCH_HOME}/tini_pub.gpg \
#   && gpg --verify /sbin/tini.asc \
#   && rm -rf /sbin/tini.asc /root/.gnupg \
#   && chmod +x /sbin/tini

EXPOSE 1099

COPY --chown=elasticsearch:elasticsearch ./config ./config
COPY --chown=elasticsearch:elasticsearch ./bin ./bin

# RUN elasticsearch-plugin remove x-pack --purge

# Ballerina runtime distribution filename.
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bossjones/elasticsearch"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="TonyDark Industries"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL maintainer="jarvis@theblacktonystark.com"
