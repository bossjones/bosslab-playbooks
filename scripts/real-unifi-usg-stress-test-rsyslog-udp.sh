#!/usr/bin/env bash

_CLUSTER=${1}

PATH_TO_MANIFEST="./vars/clear/${_CLUSTER}_manifest.yml"

# domain_root: borglab.scarlettlab.home
DNS_DOMAIN=$(grep '^domain_root:' ${PATH_TO_MANIFEST} | cut -d\: -f2 | awk '{print $1}')

for i in {0..200}; do syslog-netcat-test-udp rsyslog-centralized.${DNS_DOMAIN} 6160; done

source ./scripts/log_fixtures/usg-log-fixtures.sh

for i in "${fake_logs_security_gateway[@]}"; do echo "$i"; done
