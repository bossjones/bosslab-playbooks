#syntax=docker/dockerfile:1.3
# SOURCE: https://github.com/rsyslog/rsyslog-docker/blob/master/appliance/alpine/Dockerfile
FROM ubuntu:focal

ENV	DEBIAN_FRONTEND=noninteractive
ENV USERNAME=syslog
ENV USER_UID=101
ENV USER_GID=102

# COPY	rsyslog@lists.adiscon.com-5a55e598.rsa.pub /etc/apk/keys/rsyslog@lists.adiscon.com-5a55e598.rsa.pub
RUN	apt-get update && \
    apt install software-properties-common -y && \
    add-apt-repository ppa:adiscon/v8-stable -y && \
    sudo add-apt-repository ppa:neovim-ppa/stable -y && \
    apt-get update && \
    apt-get install sudo curl wget -y && \
    apt-get upgrade -yqq && \
    apt-get install -y gzip tar rsyslog \
    rsyslog-czmq \
    rsyslog-doc \
    rsyslog-elasticsearch \
    rsyslog-openssl \
    rsyslog-relp sudo curl htop tree net-tools psmisc xz-utils logrotate zsh vim fonts-powerline fonts-firacode git wget \
    build-essential pkg-config libestr-dev libfastjson-dev zlib1g-dev uuid-dev libgcrypt20-dev libhiredis-dev uuid-dev liblogger-syslog-perl flex bison \
    libdbi-dev libmysqlclient-dev postgresql-client libpq-dev libnet-dev librdkafka-dev libgrok-dev libgrok1 libgrok-dev libpcre3-dev libtokyocabinet-dev libglib2.0-dev libmongo-client-dev neovim
    # psmisc xz-utils logrotate rsyslog
    # echo "http://alpine.rsyslog.com/3.7/stable" >> /etc/apk/repositories \
    # && apk --no-cache update  \
    # && apk add --no-cache \
    # logrotate \
    # gzip \
    # tar \
    # pstree \
    # xz \
    # rsyslog \
    # rsyslog-elasticsearch \
    # rsyslog-imptcp \
    # rsyslog-imrelp \
    # rsyslog-mmjsonparse \
    # rsyslog-mmutf8fix \
    # rsyslog-omrelp \
    # rsyslog-omstdout \
    # bash \
    # bash-completion \
    # htop \
    # util-linux \
    # rsyslog-snmp \
    # tree \
    # net-tools \
    # ngrep

# RUN bash <(curl -sS https://raw.githubusercontent.com/nickjj/dotfiles/master/install)
RUN sh -c "$(wget -O- https://github.com/deluan/zsh-in-docker/releases/download/v1.1.2/zsh-in-docker.sh)" -- \
    -p git -p ssh-agent -p 'history-substring-search' \
    -p https://github.com/zsh-users/zsh-autosuggestions \
    -p https://github.com/zsh-users/zsh-completions

# RUN groupadd --gid $USER_GID $USERNAME \
#     && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
#     && apt-get update \
#     && apt-get install -y sudo wget \
#     && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#     && chmod 0440 /etc/sudoers.d/$USERNAME \
#     #
#     # Clean up
#     && apt-get autoremove -y \
#     && apt-get clean -y \
#     && rm -rf /var/lib/apt/lists/*
# RUN echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
#     && chmod 0440 /etc/sudoers.d/$USERNAME \
#     #
#     # Clean up
#     && apt-get autoremove -y \
#     && apt-get clean -y \
#     && rm -rf /var/lib/apt/lists/*


# RUN	adduser -s /bin/bash -D rsyslog rsyslog \
#     && echo "rsyslog ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

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
	&& chown -R $USER_UID:$USER_GID *

# SOURCE: https://hub.docker.com/r/jumanjiman/rsyslog/dockerfile

# Ballerina runtime distribution filename.
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bossjones/rsyslog"
LABEL org.label-schema.os="ubuntu"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="TonyDark Industries"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL maintainer="jarvis@theblacktonystark.com"
