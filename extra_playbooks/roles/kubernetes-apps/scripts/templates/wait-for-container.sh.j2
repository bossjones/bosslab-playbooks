#!/usr/bin/env bash

# set -e

# _CONTAINER_NAME=$1
# _CONTAINER_PORT=$2

# docker inspect --format "{{ .NetworkSettings.IPAddress }}:${_CONTAINER_PORT}" ${_CONTAINER_NAME} | xargs wget --retry-connrefused --tries=5 -q --wait=10 --spider

# source: http://jmkhael.io/collect-all-logs-from-a-docker-swarm-cluster/
function wait_for_service() {
 if [ $# -ne 1 ]
  then
    echo usage $FUNCNAME "service";
    echo e.g: $FUNCNAME docker-proxy
  else
  serviceName=$1

  while true; do
      REPLICAS=$(docker service ls | grep -E "(^| )$serviceName( |$)" | awk '{print $3}')
      if [[ $REPLICAS == "1/1" ]]; then
          break
      else
          echo "Waiting for the $serviceName service... ($REPLICAS)"
          sleep 5
      fi
  done
  fi
}
