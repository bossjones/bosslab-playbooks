FROM jumanjiman/rsyslog:8.34.0-r0-20180708T0208-git-cb867ef

# SOURCE: https://github.com/rsyslog/rsyslog-docker/blob/master/dev_env/alpine/Dockerfile
RUN	apk update;apk upgrade;apk add --no-cache \
    bash \
    bash-completion \
    htop \
    util-linux
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
