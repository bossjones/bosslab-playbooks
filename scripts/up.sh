#!/usr/bin/env bash

# SOURCE: https://github.com/gluster/gluster-kubernetes/blob/master/vagrant/up.sh

export ANSIBLE_TIMEOUT=60
vagrant up --no-provision "${@}" \
    && vagrant provision

if [ $? -eq 0 ] && [[ "x$(vagrant plugin list | grep sahara)" != "x" ]]; then
  vagrant sandbox on
fi
