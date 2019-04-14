#!/usr/bin/env bash

HOST=`hostname`
PATH_TO_ROTATE_CONFIG=${PATH_TO_ROTATE_CONFIG:-/rotate.conf}
sed -i "s/REPLACE_WITH_HOSTNAME/${HOST}/g" ${PATH_TO_ROTATE_CONFIG}

while :
do
    sleep 60
    logrotate ${PATH_TO_ROTATE_CONFIG} --verbose
done
