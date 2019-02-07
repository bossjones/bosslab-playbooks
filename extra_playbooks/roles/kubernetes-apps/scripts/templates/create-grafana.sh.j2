#!/usr/bin/env bash

set -e

# Tutorial
# source: https://botleg.com/stories/monitoring-docker-swarm-with-cadvisor-influxdb-and-grafana/

_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# source: https://github.com/grafana/grafana/issues/1789
# source: https://github.com/grafana/grafana/issues/1789#issuecomment-248309442


_GRAFANA_IP=$(docker-machine ip swarm-manager)

# source: https://stackoverflow.com/questions/31166932/create-grafana-dashboards-with-api
InstallDashboards() {
  for f in ${_DIR}/../dashboards/*; do
    curl -XPOST -i "http://admin:admin@${_GRAFANA_IP}:3000/api/dashboards/db" \
      --data-binary @${_DIR}/../dashboards/$(basename $f) \
      -H "Content-Type: application/json"
  done
}

AddDataSourceCadvisor() {
  curl "http://admin:admin@${_GRAFANA_IP}:3000/api/datasources" \
    -X POST \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary \
    '{"name":"influx","type":"influxdb","url":"http://influx:8086","access":"proxy","isDefault":true,"database":"cadvisor","basicauth":false}'
}

AddDataSourcePrometheus() {
  curl "http://admin:admin@${_GRAFANA_IP}:3000/api/datasources" \
    -X POST \
    -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary \
    '{"name":"Prometheus","type":"prometheus","url":"http://prometheus:9090","access":"proxy","isDefault":false,"database":"prometheus"}'
}

until AddDataSourcePrometheus; do
  echo 'Configuring Grafana...'
  sleep 1
done
echo 'Done!'

until AddDataSourceCadvisor; do
  echo 'Configuring Grafana...'
  sleep 1
done
echo 'Done!'

until InstallDashboards; do
  echo 'Configuring Grafana...'
  sleep 1
done
echo 'Done!'


wait
