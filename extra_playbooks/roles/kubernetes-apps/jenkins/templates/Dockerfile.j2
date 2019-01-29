FROM jenkins/jenkins:lts

ENV DOCKER_VERSION=docker-ce_17.03.0~ce-0~debian-stretch_amd64.deb \
    docker_version=17.03.0~ce-0~debian-stretch \
    KUBERNETES_VERSION=v1.13.1

#  \
# JENKINS_USER_ID="65534" \
# JENKINS_GROUP_ID="65534"

USER root

# Install prerequisites for Docker
RUN apt-get update && apt-get install -y sudo maven iptables libsystemd-dev libsystemd0 init-system-helpers libapparmor1 libltdl7 libseccomp2 libdevmapper1.02.1 && rm -rf /var/lib/apt/lists/*
# Set up Docker

RUN apt-get update && apt-get -y install \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common \
    && curl -fsSL https://download.docker.com/linux/$(. /etc/os-release; echo "$ID")/gpg > \
    /tmp/dkey; apt-key add /tmp/dkey \
    && add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
    $(lsb_release -cs) \
    stable" \
    && apt-get update && apt-cache madison docker-ce && \
    apt-get -y install docker-ce=${docker_version}

# RUN wget https://download.docker.com/linux/debian/dists/stretch/pool/stable/amd64/$DOCKER_VERSION
# RUN dpkg -i $DOCKER_VERSION
# Set up Kubernetes
RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/$KUBERNETES_VERSION/bin/linux/amd64/kubectl
RUN chmod +x ./kubectl; chown ${user}:${user} ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl
# Configure access to the Kubernetes Cluster
# ADD ../../conf/config ~/.kube
# ENTRYPOINT ["/bin/tini", "--", "/usr/local/bin/jenkins.sh"]

# SOURCE: https://www.blazemeter.com/blog/how-to-setup-scalable-jenkins-on-top-of-a-kubernetes-cluster
# Distributed Builds plugins
RUN /usr/local/bin/install-plugins.sh ssh-slaves

# install Notifications and Publishing plugins
RUN /usr/local/bin/install-plugins.sh email-ext
RUN /usr/local/bin/install-plugins.sh mailer
RUN /usr/local/bin/install-plugins.sh slack

# Artifacts
RUN /usr/local/bin/install-plugins.sh htmlpublisher

# UI
RUN /usr/local/bin/install-plugins.sh greenballs
# RUN /usr/local/bin/install-plugins.sh simple-theme-plugin

# Scaling
RUN /usr/local/bin/install-plugins.sh kubernetes

# Custom
RUN /usr/local/bin/install-plugins.sh ansicolor
RUN /usr/local/bin/install-plugins.sh antisamy-markup-formatter
RUN /usr/local/bin/install-plugins.sh authentication-tokens
RUN /usr/local/bin/install-plugins.sh aws-credentials
RUN /usr/local/bin/install-plugins.sh aws-java-sdk
RUN /usr/local/bin/install-plugins.sh blueocean
RUN /usr/local/bin/install-plugins.sh build-blocker-plugin
RUN /usr/local/bin/install-plugins.sh build-environment
RUN /usr/local/bin/install-plugins.sh build-timeout
RUN /usr/local/bin/install-plugins.sh build-user-vars-plugin
RUN /usr/local/bin/install-plugins.sh command-launcher
RUN /usr/local/bin/install-plugins.sh conditional-buildstep
RUN /usr/local/bin/install-plugins.sh copyartifact
RUN /usr/local/bin/install-plugins.sh credentials
RUN /usr/local/bin/install-plugins.sh credentials-binding
RUN /usr/local/bin/install-plugins.sh cvs
RUN /usr/local/bin/install-plugins.sh display-url-api
RUN /usr/local/bin/install-plugins.sh docker-commons
RUN /usr/local/bin/install-plugins.sh docker-workflow
RUN /usr/local/bin/install-plugins.sh durable-task
RUN /usr/local/bin/install-plugins.sh ec2
RUN /usr/local/bin/install-plugins.sh envinject
RUN /usr/local/bin/install-plugins.sh envinject-api
RUN /usr/local/bin/install-plugins.sh external-monitor-job
RUN /usr/local/bin/install-plugins.sh extra-columns
RUN /usr/local/bin/install-plugins.sh ghprb
RUN /usr/local/bin/install-plugins.sh git
RUN /usr/local/bin/install-plugins.sh git-client
RUN /usr/local/bin/install-plugins.sh github
RUN /usr/local/bin/install-plugins.sh github-api
RUN /usr/local/bin/install-plugins.sh github-branch-source
RUN /usr/local/bin/install-plugins.sh github-organization-folder
RUN /usr/local/bin/install-plugins.sh join
RUN /usr/local/bin/install-plugins.sh log-parser
RUN /usr/local/bin/install-plugins.sh mailer
RUN /usr/local/bin/install-plugins.sh matrix-auth
RUN /usr/local/bin/install-plugins.sh matrix-combinations-parameter
RUN /usr/local/bin/install-plugins.sh matrix-project
RUN /usr/local/bin/install-plugins.sh matrix-reloaded
RUN /usr/local/bin/install-plugins.sh maven-plugin
RUN /usr/local/bin/install-plugins.sh node-iterator-api
RUN /usr/local/bin/install-plugins.sh nodelabelparameter
RUN /usr/local/bin/install-plugins.sh notification
RUN /usr/local/bin/install-plugins.sh parameterized-trigger
RUN /usr/local/bin/install-plugins.sh pipeline-build-step
RUN /usr/local/bin/install-plugins.sh pipeline-github-lib
RUN /usr/local/bin/install-plugins.sh pipeline-graph-analysis
RUN /usr/local/bin/install-plugins.sh pipeline-input-step
RUN /usr/local/bin/install-plugins.sh pipeline-milestone-step
RUN /usr/local/bin/install-plugins.sh pipeline-model-api
RUN /usr/local/bin/install-plugins.sh pipeline-model-definition
RUN /usr/local/bin/install-plugins.sh pipeline-model-extensions
RUN /usr/local/bin/install-plugins.sh pipeline-rest-api
RUN /usr/local/bin/install-plugins.sh pipeline-stage-step
RUN /usr/local/bin/install-plugins.sh pipeline-stage-tags-metadata
RUN /usr/local/bin/install-plugins.sh pipeline-stage-view
RUN /usr/local/bin/install-plugins.sh plain-credentials
RUN /usr/local/bin/install-plugins.sh run-condition
# RUN /usr/local/bin/install-plugins.sh scm-api
RUN /usr/local/bin/install-plugins.sh script-security
RUN /usr/local/bin/install-plugins.sh ssh-agent
RUN /usr/local/bin/install-plugins.sh ssh-credentials
RUN /usr/local/bin/install-plugins.sh subversion
RUN /usr/local/bin/install-plugins.sh template-project
RUN /usr/local/bin/install-plugins.sh text-finder-run-condition
RUN /usr/local/bin/install-plugins.sh timestamper
RUN /usr/local/bin/install-plugins.sh token-macro
RUN /usr/local/bin/install-plugins.sh translation
# RUN /usr/local/bin/install-plugins.sh workflow-aggregator
# RUN /usr/local/bin/install-plugins.sh workflow-basic-steps
# RUN /usr/local/bin/install-plugins.sh workflow-cps
# RUN /usr/local/bin/install-plugins.sh workflow-job
# RUN /usr/local/bin/install-plugins.sh workflow-multibranch
# RUN /usr/local/bin/install-plugins.sh workflow-scm-step
# RUN /usr/local/bin/install-plugins.sh workflow-step-api
# RUN /usr/local/bin/install-plugins.sh workflow-support
RUN /usr/local/bin/install-plugins.sh ws-cleanup
RUN /usr/local/bin/install-plugins.sh xunit

# USER jenkins

# ENV UID_JENKINS=1000
# ENV GID_JENKINS=1000
ENV UID_JENKINS=65534
ENV GID_JENKINS=65534

COPY docker-entrypoint.sh /docker-entrypoint.sh

RUN set -eux; \
curl -L 'https://github.com/tianon/gosu/releases/download/1.11/gosu-amd64' > /usr/local/bin/gosu && \
chmod +x /usr/local/bin/gosu

ENTRYPOINT ["/sbin/tini", "--", "/docker-entrypoint.sh"]

# Ballerina runtime distribution filename.
ARG BUILD_DATE
ARG VCS_REF
ARG BUILD_VERSION


MAINTAINER TonyDark Jarvis <jarvis@theblacktonystark.com>

LABEL maintainer="jarvis@theblacktonystark.com"

# Labels.
LABEL org.label-schema.schema-version="1.0"
LABEL org.label-schema.build-date=$BUILD_DATE
LABEL org.label-schema.name="bossjones/jenkins"
LABEL org.label-schema.description="Jenkins"
LABEL org.label-schema.url="https://jenkins.io/"
LABEL org.label-schema.vcs-url="https://github.com/jenkinsci/docker/blob/master/Dockerfile"
LABEL org.label-schema.vcs-ref=$VCS_REF
LABEL org.label-schema.vendor="TonyDark Industries"
LABEL org.label-schema.version=$BUILD_VERSION
LABEL org.label-schema.docker.cmd="docker run -p 8080:8080 -p 50000:50000 -v jenkins_home:/var/jenkins_home bossjones/jenkins:latest"
