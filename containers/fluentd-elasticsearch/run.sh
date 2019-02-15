#!/bin/bash


# NOTE: Fix issue where mantra hides errors to stderr
# SOURCE: https://stackoverflow.com/questions/3173131/redirect-copy-of-stdout-to-log-file-from-within-bash-script-itself
# Without this, only stdout would be captured - i.e. your
# log file would not contain any error messages.
# SEE (and upvote) the answer by Adam Spiers, which keeps STDERR
# as a separate stream - I did not want to steal from him by simply
# adding his answer to mine.
exec 2>&1

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


exec supervisord -n -c /etc/supervisor/supervisord.conf
