# SOURCE: https://github.com/rsyslog/rsyslog-docker/blob/master/appliance/alpine/Dockerfile
FROM alpine:3.7
COPY	rsyslog@lists.adiscon.com-5a55e598.rsa.pub /etc/apk/keys/rsyslog@lists.adiscon.com-5a55e598.rsa.pub
COPY entrypoint.sh /entrypoint.sh
COPY rotate.conf /rotate.conf

RUN	echo "http://alpine.rsyslog.com/3.7/stable" >> /etc/apk/repositories \
    && apk --no-cache update  \
    && apk add --no-cache \
    logrotate \
    gzip \
    tar \
    pstree \
    xz \
    bash \
    bash-completion \
    htop \
    util-linux \
    tree \
    net-tools \
    ngrep && \
    chmod 600 /rotate.conf

ENTRYPOINT ["/entrypoint.sh"]

# Ballerina runtime distribution filename.
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bossjones/logrotate"
LABEL org.label-schema.os="alpine"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="TonyDark Industries"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL maintainer="jarvis@theblacktonystark.com"
