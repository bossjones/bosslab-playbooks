#!/usr/bin/env bash
# Common functions used in scripts run by MSP Jenkins

# https://github.com/liaoya/notebook/blob/a7748c673681912cbc06ca33f837b77e7a75a23b/cloud/kubernetes/k8s-functions.sh

# yq has problem to put yaml file directly
[[ $(command -v yq) ]] || { echo "The function is depended on yq (https://github.com/mikefarah/yq) command heavily"; exit 1; }

_TMP_DIR=$(mktemp -d)

check_k8s_yaml() {
    local tracestate
    tracestate="$(shopt -po xtrace)"
    set +x

    if [[ $# -ne 1 ]]; then
        echo "Usage: ${FUNCNAME[0]} <K8S yaml file>"
        return 1
    elif [[ ! -f $1 ]]; then
        echo "$1 does not exist"
        return 1
    fi

    if [[ $(command -v kubeval) ]]; then
        if ! grep -s -q "^apiVersion: occloud.oracle.com" "$1"; then
            kubeval "$1" < /dev/null || { echo "$1 is invalid"; cat "$1"; return 1; }
        else
            echo "$1 is occloud extension"
            cat "$1"
        fi
    fi
    [[ -n "${tracestate}" ]] && eval "${tracestate}"
}

create_configmap_yaml_from_cmd() {
    if [[ $((($#)%2)) -eq 0 && $# -ge 4 ]]; then
        local tracestate
        tracestate="$(shopt -po xtrace)"
        set +x

        local yamlfile=$1; shift;
        local name=$1; shift

        cat > "${yamlfile}" << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${name}
EOF
        local key
        local value
        while  (( "$#")); do
            key=$1; shift; value=$1; shift
            yq w -i "${yamlfile}" data["${key}"] "${value}"
        done
        if [[ $(command -v kubeval) ]]; then kubeval "${yamlfile}"; fi
        cat "${yamlfile}"
        [[ -n "${tracestate}" ]] && eval "${tracestate}"
    else
        echo "Usage: ${FUNCNAME[0]} <yaml file> <secret name> <key> <value> [key] [value]..."
        return 1
    fi
}

create_configmap_from_cmd() {
    if [[ $((($#)%2)) -eq 0 && $# -ge 4 ]]; then
        local ns; ns=$1; shift
        local name; name=$1; shift
        local yamlfile; yamlfile="${_TMP_DIR}/configmap-${name}.yml"
        if create_configmap_yaml_from_cmd "${yamlfile}" "${name}" "$@"; then
            kubectl apply -f "${yamlfile}" --namespace "${ns}"
        fi
    else
        echo "Usage: ${FUNCNAME[0]} <namespace> <configmap name> <key> <value> [key] [value]..."
        return 1
    fi
}

create_configmap_yaml_from_dir() {
    if [[ $# -eq 3 ]]; then
        local tracestate
        tracestate="$(shopt -po xtrace)"
        set +x

        local yamlfile=$1; shift
        local name=$1; shift
        local folder=$1
        folder=$(readlink -f "${folder}")
        [[ -d ${folder} ]] || { echo "${folder} does not exist"; exit 1; }
        cat > "${yamlfile}" << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${name}
EOF
        local key
        local value
        for item in "${folder}"/*; do
            if [[ -f ${item} ]]; then
                key=$(basename "${item}")
                value=$(cat "${item}")
                yq w -i "${yamlfile}" data["${key}"] "${value}"
            fi
        done
        if [[ $(command -v kubeval ) ]]; then kubeval "${yamlfile}"; fi
        cat "${yamlfile}"
        [[ -n "${tracestate}" ]] && eval "${tracestate}"
    else
        echo "Usage: ${FUNCNAME[0]} <yaml file name> <configmap name> <folder>"
        exit 1
    fi
}

create_configmap_from_dir() {
    if [[ $# -eq 3 ]]; then
        local yamlfile; yamlfile="${_TMP_DIR}/configmap-${2}.yml"
        create_configmap_yaml_from_dir "${yamlfile}" "$2" "$3"
        kubectl apply -f "${yamlfile}" --namespace "${1}"
    else
        echo "Usage: ${FUNCNAME[0]} <namespace> <configmap name> <folder>"
        return 1
    fi
}

create_configmap_yaml_from_files() {
    if [[ $# -ge 3 ]]; then
        local tracestate
        tracestate="$(shopt -po xtrace)"
        set +x

        local yamlfile=$1; shift
        local name=$1; shift

        cat > "${yamlfile}" << EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${name}
EOF
        local key
        local value
        while (( "$#")); do
            item=$1; shift;
            if [[ -f ${item} ]]; then
                key=$(basename "${item}")
                value=$(cat "${item}")
                yq w -i "${yamlfile}" data["${key}"] "${value}"
            else
                echo "${item} does not exist"
                rm -f "${yamlfile}"
                return
            fi
        done
        if [[ $(command -v kubeval ) ]]; then kubeval "${yamlfile}"; fi
        cat "${yamlfile}"
        [[ -n "${tracestate}" ]] && eval "${tracestate}"
    else
        echo "Usage: ${FUNCNAME[0]} <yaml file name> <configmap name> <file> [file] ..."
        exit 1
    fi
}

create_configmap_from_files() {
    if [[ $# -ge 3 ]]; then
        local ns; ns=$1; shift
        local name; name=$1; shift
        local yamlfile; yamlfile="${_TMP_DIR}/configmap-${name}.yml"
        if create_configmap_yaml_from_files "${yamlfile}" "${name}" "$@"; then
            kubectl apply -f "${yamlfile}" --namespace "${ns}"
        fi
    else
        echo "Usage: ${FUNCNAME[0]} <namespace> <configmap name> <file> [file] ..."
        return 1
    fi
}

create_secret_yaml_from_cmd() {
    if [[ $((($#)%2)) -eq 0 && $# -ge 4 ]]; then
        local tracestate
        tracestate="$(shopt -po xtrace)"
        set +x

        local yamlfile=$1; shift;
        local name=$1; shift

        cat > "${yamlfile}" << EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${name}
type: Opaque
EOF
        local key
        local value
        while  (( "$#")); do
            key=$1; shift; value=$1; shift
            value=$(echo "${value}" | base64 -w 0)
            yq w -i "${yamlfile}" data["${key}"] "${value}"
        done
        if [[ $(command -v kubeval) ]]; then kubeval "${yamlfile}"; fi
        cat "${yamlfile}"
        [[ -n "${tracestate}" ]] && eval "${tracestate}"
    else
        echo "Usage: ${FUNCNAME[0]} <yaml file> <secret name> <key> <value> [key] [value]..."
        return 1
    fi
}

create_secret_from_cmd() {
    if [[ $((($#)%2)) -eq 0 && $# -ge 4 ]]; then
        local ns=$1; shift
        local name=$1; shift
        local yamlfile; yamlfile="${_TMP_DIR}/secret-${name}.yml"
        if create_secret_yaml_from_cmd "${yamlfile}" "${name}" "$@"; then
            kubectl apply -f "${yamlfile}" --namespace "${ns}"
        fi
    else
        echo "Usage: ${FUNCNAME[0]} <namespace> <secret name> <key> <value> [key] [value]..."
        return 1
    fi
}

create_secret_yaml_from_dir() {
    if [[ $# -eq 3 ]]; then
        local tracestate
        tracestate="$(shopt -po xtrace)"
        set +x

        local yamlfile=$1; shift
        local name=$1; shift
        local folder=$1; shift
        folder=$(readlink -f "${folder}")
        [[ -d ${folder} ]] || { echo "${folder} does not exist"; return 1; }
        local yamlfile; yamlfile="${_TMP_DIR}/secret-${name}.yml"
        cat > "${yamlfile}" << EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${name}
type: Opaque
EOF
        local key
        local value
        for item in "${folder}"/*; do
            if [[ -f ${item} ]]; then
                key=$(basename "${item}")
                value=$(base64 -w 0 "${item}")
                yq w -i "${yamlfile}" data["${key}"] "${value}"
            fi
        done
        if [[ $(command -v kubeval) ]]; then kubeval "${yamlfile}"; fi
        cat "${yamlfile}"
        [[ -n "${tracestate}" ]] && eval "${tracestate}"
    else
        echo "Usage: ${FUNCNAME[0]} <yaml file> <secret name> <folder>"
        return 1
    fi
}

create_secret_from_dir() {
    if [[ $# -eq 3 ]]; then
        local ns=$1; shift
        local name=$1; shift
        local yamlfile; yamlfile="${_TMP_DIR}/secret-${name}.yml"
        if create_secret_yaml_from_dir "${yamlfile}" "${name}" "$@"; then
            kubectl apply -f "${yamlfile}" --namespace "${ns}"
        fi
        [[ -d ${folder} ]] || { echo "${folder} does not exist"; return 1; }
    else
        echo "Usage: ${FUNCNAME[0]} <namespace> <secret name> <folder>"
        return 1
    fi
}

create_secret_yaml_from_files() {
    if [[ $# -ge 3 ]]; then
        local tracestate
        tracestate="$(shopt -po xtrace)"
        set +x

        local ns=$1; shift
        local name=$1; shift
        local yamlfile; yamlfile="${_TMP_DIR}/secret-${name}.yml"

        cat > "${yamlfile}" << EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${name}
type: Opaque
EOF
        local key
        local value
        while (( "$#")); do
            item=$1; shift;
            if [[ -f ${item} ]]; then
                key=$(basename "${item}")
                value=$(base64 -w 0 "${item}")
                yq w -i "${yamlfile}" data["${key}"] "${value}"
            else
                echo "${item} does not exist"
                return 1
            fi
        done
        [[ -n "${tracestate}" ]] && eval "${tracestate}"
        cat "${yamlfile}"
        if [[ $(command -v kubeval) ]]; then kubeval "${yamlfile}"; fi
        kubectl apply -f "${yamlfile}" --namespace "${ns}"
    else
        echo "Usage: ${FUNCNAME[0]} <namespace> <secret name> <file> [file] ..."
        return 1
    fi
}

create_secret_from_files() {
    if [[ $# -ge 3 ]]; then
        local ns=$1; shift
        local name=$1; shift
        local yamlfile; yamlfile="${_TMP_DIR}/secret-${name}.yml"
        if create_secret_yaml_from_dir "${yamlfile}" "${name}" "$@"; then
            kubectl apply -f "${yamlfile}" --namespace "${ns}"
        fi
        [[ -d ${folder} ]] || { echo "${folder} does not exist"; return 1; }
    else
        echo "Usage: ${FUNCNAME[0]} <namespace> <secret name> <file> [file] .."
        return 1
    fi
}
