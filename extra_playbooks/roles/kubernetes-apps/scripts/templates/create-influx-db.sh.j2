#!/usr/bin/env bash

set -e

# source: https://docs.influxdata.com/influxdb/v1.3/guides/writing_data/

_INFLUX_IP=$(docker-machine ip swarm-manager)

CreateCadvisorDatabase() {
  curl -i -XPOST http://${_INFLUX_IP}:8086/query --data-urlencode "q=CREATE DATABASE cadvisor"
  docker exec `docker ps | grep -i influx | awk '{print $1}'` influx -execute 'CREATE DATABASE cadvisor'
}

until CreateCadvisorDatabase; do
  echo 'Configuring Cadvisor...'
  sleep 1
done
echo 'Done!'

wait
