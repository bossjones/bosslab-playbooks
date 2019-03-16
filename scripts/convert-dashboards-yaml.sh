my_array=( $(pwd)/boards/netdata_dashboard.json $(pwd)/boards/kubernetes_statefulset.json $(pwd)/boards/docker_and_host_mintoring_w_prometheus.json $(pwd)/boards/kubernetes_deployment_statefulset_daemonset_metrics.json $(pwd)/boards/node_exporter_for_prometheus.json $(pwd)/boards/docker_and_system_monitoring.json $(pwd)/boards/docker_host_and_container_overview.json $(pwd)/boards/fluentd_dashboard.json $(pwd)/boards/node_exporter_full.json $(pwd)/boards/alerts_linux_nodes.json $(pwd)/boards/elasticsearch_logs_from_fluentd.json $(pwd)/boards/kubernetes_pods_dashboard.json $(pwd)/boards/kubeless.json $(pwd)/boards/alertmanager.json $(pwd)/boards/kubernetes_pods.json $(pwd)/boards/netdata.json $(pwd)/boards/stats_at_a_glance_for_home_infra.json $(pwd)/boards/unifi_ap_dashboard.json $(pwd)/boards/unifi_controller_dashboard.json $(pwd)/boards/kubernetes_all_nodes.json $(pwd)/boards/analysis_by_pod.json $(pwd)/boards/analysis_by_cluster.json $(pwd)/boards/analysis_by_namespace.json $(pwd)/boards/kubernetes_cluster_autoscaler.json )

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
    ${_filename}: |-
      $(/bin/cat $i | jq --indent 7 .)
  kind: ConfigMap
  metadata:
    name: grafana-dashboard-$(echo $_filename)
    namespace: monitoring
EOF

done


cat $(pwd)/boards_yaml/* > $(pwd)/boards_yaml/final.yaml

# echo "Nuke $(pwd)/boards/final.yaml"
# > $(pwd)/boards_yaml/final.yaml
# > $(pwd)/boards_yaml/final.yaml

for i in "${my_array[@]}"; do
    echo "$i";
    _NEW_NAME=$(echo $i | sed 's,.json,.yaml,g' |  sed 's,boards,boards_yaml,g')
    # /bin/cat ${_NEW_NAME} >> $(pwd)/boards/final.yaml
    rm ${_NEW_NAME}
done
