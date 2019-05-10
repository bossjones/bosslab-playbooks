#!/usr/bin/env bash

_PATTERNS_DIR=${1}
_PATTERN=${2}

if [[ "${_PATTERNS_DIR}" = "fluentd" ]]; then
    _PATH_TO_PATTERNS=containers/groktoregex/patterns_fluentd_grok_parser/

else
    _PATH_TO_PATTERNS=containers/groktoregex/patterns_standard/
fi

groktoregex --grok ${_PATTERN} --source ${_PATH_TO_PATTERNS}
