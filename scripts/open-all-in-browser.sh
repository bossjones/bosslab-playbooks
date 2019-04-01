#!/usr/bin/env bash

_CLUSTER=${1}

PATH_TO_MANIFEST="./vars/clear/${_CLUSTER}_manifest.yml"

# domain_root: borglab.scarlettlab.home
DNS_DOMAIN=$(grep '^domain_root:' ${PATH_TO_MANIFEST} | cut -d\: -f2 | awk '{print $1}')

my_array=( "http://whoami.${DNS_DOMAIN}" "http://echoserver.${DNS_DOMAIN}" "http://elasticsearch.${DNS_DOMAIN}" "http://kibana.${DNS_DOMAIN}" "http://prometheus.${DNS_DOMAIN}" "http://grafana.${DNS_DOMAIN}" "http://alertmanager.${DNS_DOMAIN}" "http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/" )

for i in "${my_array[@]}"; do ./scripts/open-browser.py "${i}"; done


