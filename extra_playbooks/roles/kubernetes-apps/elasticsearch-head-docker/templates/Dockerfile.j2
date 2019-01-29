FROM index.docker.io/node:10.15.0-stretch-slim
MAINTAINER TonyDark Jarvis <jarvis@theblacktonystark.com>

ENV \
LANG=C.UTF-8

RUN apt-get update; apt-get install sudo vim wget tar tree curl unzip bzip2 -y; apt-get clean -y && \
    rm -rf \
        /var/cache/debconf/* \
        /var/lib/apt/lists/* \
        /var/log/* \
        /tmp/* \
        /var/tmp/*

EXPOSE 9100

WORKDIR /opt

RUN curl -L 'https://github.com/mobz/elasticsearch-head/archive/master.zip' > /usr/local/src/master.zip && \
    unzip /usr/local/src/master.zip -d /opt/ && \
    mv -fv /opt/elasticsearch-head-master/ /opt/app

# unzip -d "$dest" "$zip" && f=("$dest"/*) && mv "$dest"/*/* "$dest" && rmdir "${f[@]}"

WORKDIR /opt/app

RUN npm install -g grunt

RUN npm install


# https://github.com/mobz/elasticsearch-head/archive/v5.0.0.zip
# https://github.com/mobz/elasticsearch-head/archive/master.zip
# 1  mkdir -p /usr/src/app
# 	2  cd /usr/src/app
# 	3  npm install -g grunt
# 	4  apt-get update; apt-get install curl -y
# 	5  curl -L 'https://github.com/mobz/elasticsearch-head/archive/master.zip' > master.zip
# 	6  file master.zip
# 	7  apt-get install unzip -y
# 	8  unzip master.zip
# 	9  ls
# 10  cd elasticsearch-head-master/
# 11  ls
# 12  apt-get install vim -y
# 13  npm install
# 14  npm audit fix
# 15  grunt server
# 16  npm audit fix --force
# 17  grunt server
# 18  history
# find . -type f -exec sed -i 's/localhost:9200/elasticsearch-logging:9200/g' {} +

# COPY --chown=elasticsearch:elasticsearch ./config ./config
# COPY --chown=elasticsearch:elasticsearch ./bin ./bin

ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bossjones/elasticsearch-head"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="TonyDark Industries"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL maintainer="jarvis@theblacktonystark.com"
