#!/usr/bin/env bash

set -euxo pipefail

# source: https://blog.couchbase.com/enabling-docker-remote-api-docker-machine-mac-osx/
# source: https://blog.couchbase.com/monitoring-docker-containers-docker-stats-cadvisor-universal-control-plane/

cd ~/.docker/machine/machines/swarm-manager && \
openssl pkcs12 -export -inkey key.pem -in cert.pem -CAfile ca.pem -chain -name client-side  -out cert.p12 -password pass:mypass && \

cd ~/.docker/machine/machines/node-01 && \
openssl pkcs12 -export -inkey key.pem -in cert.pem -CAfile ca.pem -chain -name client-side  -out cert.p12 -password pass:mypass && \

cd ~/.docker/machine/machines/node-02 && \
openssl pkcs12 -export -inkey key.pem -in cert.pem -CAfile ca.pem -chain -name client-side  -out cert.p12 -password pass:mypass && \

cd ~/.docker/machine/machines/node-03 && \
openssl pkcs12 -export -inkey key.pem -in cert.pem -CAfile ca.pem -chain -name client-side  -out cert.p12 -password pass:mypass

# Test curl to each stats endpoint for each host!
_HOST=$(docker-machine ip swarm-manager)
_DOCKER_CERT_PATH=~/.docker/machine/machines/swarm-manager
curl https://$_HOST:2376/images/json --cert $_DOCKER_CERT_PATH/cert.p12 --pass mypass --key $_DOCKER_CERT_PATH/key.pem --cacert $_DOCKER_CERT_PATH/ca.pem

_HOST=$(docker-machine ip node-01)
_DOCKER_CERT_PATH=~/.docker/machine/machines/node-01
curl https://$_HOST:2376/images/json --cert $_DOCKER_CERT_PATH/cert.p12 --pass mypass --key $_DOCKER_CERT_PATH/key.pem --cacert $_DOCKER_CERT_PATH/ca.pem

_HOST=$(docker-machine ip node-02)
_DOCKER_CERT_PATH=~/.docker/machine/machines/node-02
curl https://$_HOST:2376/images/json --cert $_DOCKER_CERT_PATH/cert.p12 --pass mypass --key $_DOCKER_CERT_PATH/key.pem --cacert $_DOCKER_CERT_PATH/ca.pem

_HOST=$(docker-machine ip node-03)
_DOCKER_CERT_PATH=~/.docker/machine/machines/node-03
curl https://$_HOST:2376/images/json --cert $_DOCKER_CERT_PATH/cert.p12 --pass mypass --key $_DOCKER_CERT_PATH/key.pem --cacert $_DOCKER_CERT_PATH/ca.pem
