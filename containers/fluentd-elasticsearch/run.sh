#!/bin/bash

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# These steps must be executed once the host /var and /lib volumes have
# been mounted, and therefore cannot be done in the docker build stage.

# For systems without journald
mkdir -p /var/log/journal

# /usr/local/bin/fluentd $@

# # SOURCE: https://dev.maxmind.com/geoip/geoip2/geolite2/
# mkdir -p ./geoip || true && \
# cd ./geoip && \
# curl -L "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-City&license_key=${GEOLITE2_YOUR_LICENSE_KEY}&suffix=tar.gz" > GeoLite2-City.tar.gz && \
# curl -L "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=${GEOLITE2_YOUR_LICENSE_KEY}&suffix=tar.gz" > GeoLite2-Country.tar.gz && \
# curl -L "https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-ASN&license_key=${GEOLITE2_YOUR_LICENSE_KEY}&suffix=tar.gz" > GeoLite2-ASN.tar.gz && \
# gunzip GeoLite2-City.tar.gz && \
# gunzip GeoLite2-Country.tar.gz && \
# gunzip GeoLite2-ASN.tar.gz && \
# tar -xvf GeoLite2-City.tar && \
# tar -xvf GeoLite2-Country.tar && \
# tar -xvf GeoLite2-ASN.tar && \
# mv -v GeoLite2-*/*.mmdb . && \
# rm -rfv GeoLite2-{ASN,City,Country}_* && \
# rm -rfv *.tar && \
# rm -rfv *.tar.gz
# cd -
# set +x


# # Start Fluentd-ui process
# /usr/local/bin/fluentd-ui start --daemonize
# status=$?
# if [ $status -ne 0 ]; then
#   echo "Failed to start fluentd-ui: $status"
#   exit $status
# fi

# # Start Fluentd process
# /usr/local/bin/fluentd $@
# status=$?
# if [ $status -ne 0 ]; then
#   echo "Failed to start fluentd: $status"
#   exit $status
# fi

# TODO: Maybe enable this
# SOURCE: https://medium.com/lucjuggery/running-a-container-with-a-non-root-user-e35830d1f42a
# allow the container to be started with ` — user
# all mongo* commands should be dropped to the correct user
# if [[ "$originalArgOne" == mongo* ]] && [ "$(id -u)" = '0' ]; then
#     if [ "$originalArgOne" = 'mongod' ];
#         then chown -R mongodb /data/configdb /data/db
#     fi
#     # make sure we can write to stdout and stderr as "mongodb"
#     # (for our "initdb" code later; see " — logpath" below)
#     chown --dereference mongodb "/proc/$$/fd/1" "/proc/$$/fd/2" || :
#     exec gosu mongodb "$BASH_SOURCE" "$@"
# fi
# Even better than article: https://github.com/docker-library/mongo/blob/master/4.0/docker-entrypoint.sh


# exec supervisord -n -c /etc/supervisor/supervisord.conf


# NOTE: Fix issue where mantra hides errors to stderr
# SOURCE: https://stackoverflow.com/questions/3173131/redirect-copy-of-stdout-to-log-file-from-within-bash-script-itself
# Without this, only stdout would be captured - i.e. your
# log file would not contain any error messages.
# SEE (and upvote) the answer by Adam Spiers, which keeps STDERR
# as a separate stream - I did not want to steal from him by simply
# adding his answer to mine.
exec 2>&1

# Use exec to get the signal
# A non-quoted string and add the comment to prevent shellcheck failures on this line.
# See https://github.com/koalaman/shellcheck/wiki/SC2086
# shellcheck disable=SC2086
# exec /usr/local/bin/fluentd "${FLUENTD_ARGS}"
exec /usr/local/bin/fluentd $(echo ${FLUENTD_ARGS} | xargs)
# exec gosu root /usr/local/bin/fluentd "$@"
