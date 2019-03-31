#!/usr/bin/env bash

my_array=( $(pwd)/scripts/boards/netdata_dashboard.json $(pwd)/scripts/boards/kubernetes_statefulset.json $(pwd)/scripts/boards/docker_and_host_mintoring_w_prometheus.json $(pwd)/scripts/boards/kubernetes_deployment_statefulset_daemonset_metrics.json $(pwd)/scripts/boards/node_exporter_for_prometheus.json $(pwd)/scripts/boards/docker_and_system_monitoring.json $(pwd)/scripts/boards/docker_host_and_container_overview.json $(pwd)/scripts/boards/fluentd_dashboard.json $(pwd)/scripts/boards/node_exporter_full.json $(pwd)/scripts/boards/alerts_linux_nodes.json $(pwd)/scripts/boards/elasticsearch_logs_from_fluentd.json $(pwd)/scripts/boards/kubernetes_pods_dashboard.json $(pwd)/scripts/boards/kubeless.json $(pwd)/scripts/boards/alertmanager.json $(pwd)/scripts/boards/kubernetes_pods.json $(pwd)/scripts/boards/netdata.json $(pwd)/scripts/boards/stats_at_a_glance_for_home_infra.json $(pwd)/scripts/boards/unifi_ap_dashboard.json $(pwd)/scripts/boards/unifi_controller_dashboard.json $(pwd)/scripts/boards/kubernetes_all_nodes.json $(pwd)/scripts/boards/analysis_by_pod.json $(pwd)/scripts/boards/analysis_by_cluster.json $(pwd)/scripts/boards/analysis_by_namespace.json $(pwd)/scripts/boards/kubernetes_cluster_autoscaler.json )

for i in "${my_array[@]}"; do echo "$i"; done


# SOURCE: https://stackoverflow.com/questions/17484774/indenting-multi-line-output-in-a-shell-script
indent() { gsed 's/^/        /'; }

for i in "${my_array[@]}"; do
    echo "$i";
    _filename=$(basename -- "${i}")
    _extension="${_filename##*.}"
    _filename="${_filename%.*}"

    _NEW_NAME=$(echo $i | sed 's,.json,.yaml,g' |  sed 's,boards,boards_yaml,g')
    # _CONTENTS=$(/bin/cat $i | python -m json.tool)
    _CONTENTS=$(/bin/cat $i | jq --indent 7 .)

    #   $(echo ${_CONTENTS} | indent)
    cat <<EOF > ${_NEW_NAME}
- apiVersion: v1
  data:
    ${_filename}.json: |-
      $(/bin/cat $i | jq --indent 7 .)
  kind: ConfigMap
  metadata:
    name: grafana-dashboard-$(echo $_filename | sed 's,_,-,g')
    namespace: monitoring
EOF

done


# Consolidate into one yaml file that is easy to copy and paste
cat $(pwd)/scripts/boards_yaml/* > $(pwd)/scripts/boards_yaml/final.yaml

# incorrect spacing for some of these json values, simply indent them w/ 6 spaces
gsed -i 's,^\},      \},g' $(pwd)/scripts/boards_yaml/final.yaml

# gsed -i 's,${DS_PROMETHEUS},$datasource,g' $(pwd)/scripts/boards_yaml/final.yaml

# # Optional, change all of the datasources into Prometheus
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"Prometheus\"|g' $(pwd)/scripts/boards_yaml/final.yaml

# nuke all the other artifacts, everything should be in final.yaml at this point
for i in "${my_array[@]}"; do
    echo "$i";
    _NEW_NAME=$(echo $i | sed 's,.json,.yaml,g' |  sed 's,boards,boards_yaml,g')
    rm ${_NEW_NAME}
done
