#!/bin/bash

# NOTE: Fix issue where mantra hides errors to stderr
# SOURCE: https://stackoverflow.com/questions/3173131/redirect-copy-of-stdout-to-log-file-from-within-bash-script-itself
# Without this, only stdout would be captured - i.e. your
# log file would not contain any error messages.
# SEE (and upvote) the answer by Adam Spiers, which keeps STDERR
# as a separate stream - I did not want to steal from him by simply
# adding his answer to mine.
exec 2>&1

exec rsyslogd -n -f/etc/rsyslog.conf -M.
