# SOURCE: https://github.com/rsyslog/rsyslog-docker/blob/master/appliance/alpine/Dockerfile
FROM alpine:3.7
COPY	rsyslog@lists.adiscon.com-5a55e598.rsa.pub /etc/apk/keys/rsyslog@lists.adiscon.com-5a55e598.rsa.pub
RUN	echo "http://alpine.rsyslog.com/3.7/stable" >> /etc/apk/repositories \
    && apk --no-cache update  \
    && apk add --no-cache \
    logrotate \
    gzip \
    tar \
    xz \
    rsyslog \
    rsyslog-elasticsearch \
    rsyslog-imptcp \
    rsyslog-imrelp \
    rsyslog-mmjsonparse \
    rsyslog-mmutf8fix \
    rsyslog-omrelp \
    rsyslog-omstdout \
    bash \
    bash-completion \
    htop \
    util-linux \
    rsyslog-snmp \
    tree \
    net-tools \
    ngrep

RUN	adduser -s /bin/bash -D rsyslog rsyslog \
    && echo "rsyslog ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# VOLUME	/config /work /logs
CMD	["rsyslog"]
ENTRYPOINT ["/home/appliance/starter.sh"]

COPY	rsyslog.conf /etc/rsyslog.conf
COPY	rsyslog.conf.d/*.conf /etc/rsyslog.conf.d/


WORKDIR /home/appliance
COPY	starter.sh CONTAINER.* ./
COPY	internal/* ./internal/
COPY	tools/* ./tools/
RUN	echo "`date +%F` (`date +%s`)" > CONTAINER.release \
	&& chown -R rsyslog:rsyslog *

# SOURCE: https://github.com/rsyslog/rsyslog-docker/blob/master/dev_env/alpine/Dockerfile
# RUN	apk update;apk upgrade;apk add --no-cache \
#     bash \
#     bash-completion \
#     htop \
#     util-linux

# RUN	apk update;apk upgrade;apk add --no-cache \
# 		git build-base automake libtool autoconf py-docutils gnutls gnutls-dev \
# 		zlib-dev curl-dev mysql-dev libdbi-dev libuuid util-linux-dev \
# 		libgcrypt-dev flex bison bsd-compat-headers linux-headers valgrind librdkafka-dev \
# 		autoconf-archive \
# 		libestr-dev \
# 		libfastjson-dev \
# 		liblognorm-dev \
# 		librelp-dev \
# 		liblogging-dev \
		# bash \
        # bash-completion \
        # htop

# SOURCE: https://hub.docker.com/r/jumanjiman/rsyslog/dockerfile

# Ballerina runtime distribution filename.
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bossjones/rsyslog"
LABEL org.label-schema.os="alpine"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="TonyDark Industries"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL maintainer="jarvis@theblacktonystark.com"
