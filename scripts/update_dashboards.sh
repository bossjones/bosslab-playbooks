#!/usr/bin/env bash

# SOURCE: https://github.com/xiaomatech/dashboard/blob/edf8f614f68bba043847145a519807b0f1ca80e6/update_dashboard.sh
# wget https://grafana.com/api/dashboards/1124/revisions/4/download -O $(pwd)/boards/prometheus_snmp_network.json
# wget https://grafana.com/api/dashboards/1666/revisions/1/download -O $(pwd)/boards/prometheus_bind.json
# wget https://grafana.com/api/dashboards/2322/revisions/3/download -O $(pwd)/boards/prometheus_elasticsearch.json
# wget https://grafana.com/api/dashboards/3070/revisions/3/download -O $(pwd)/boards/prometheus_etcd.json
# wget https://grafana.com/api/dashboards/2525/revisions/1/download -O $(pwd)/boards/prometheus_logstash.json
# wget https://grafana.com/api/dashboards/2121/revisions/1/download -O $(pwd)/boards/prometheus_rabbitmq.json
# wget https://grafana.com/api/dashboards/2113/revisions/1/download -O $(pwd)/boards/prometheus_hystrix.json
# wget https://grafana.com/api/dashboards/3901/revisions/1/download -O $(pwd)/boards/prometheus_php-fpm.json
# wget https://grafana.com/api/dashboards/2040/revisions/4/download -O $(pwd)/boards/prometheus_tidb.json
# wget https://grafana.com/api/dashboards/2043/revisions/8/download -O $(pwd)/boards/prometheus_tikv.json
# wget https://grafana.com/api/dashboards/2037/revisions/4/download -O $(pwd)/boards/prometheus_pd.json
# wget https://grafana.com/api/dashboards/3457/revisions/1/download -O $(pwd)/boards/prometheus_jmx.json
# wget https://grafana.com/api/dashboards/2949/revisions/1/download -O $(pwd)/boards/prometheus_nginx_vts.json
# wget https://grafana.com/api/dashboards/926/revisions/1/download -O $(pwd)/boards/prometheus_ceph_pools.json
# wget https://grafana.com/api/dashboards/923/revisions/1/download -O $(pwd)/boards/prometheus_ceph_osd.json
# wget https://grafana.com/api/dashboards/917/revisions/1/download -O $(pwd)/boards/prometheus_ceph_cluster.json
# wget https://grafana.com/api/dashboards/2030/revisions/1/download -O $(pwd)/boards/system_metrics.json
# wget https://grafana.com/api/dashboards/2711/revisions/3/download -O $(pwd)/boards/zabbix.json
# wget https://grafana.com/api/dashboards/3244/revisions/1/download -O $(pwd)/boards/kubernetes_calico.json
# wget https://grafana.com/api/dashboards/741/revisions/1/download -O $(pwd)/boards/kubernetes_deployment.json
# wget https://grafana.com/api/dashboards/315/revisions/3/download -O $(pwd)/boards/kubernetes.json
# wget https://grafana.com/api/dashboards/405/revisions/6/download -O $(pwd)/boards/kubernetes_node.json
# wget https://grafana.com/api/dashboards/1860/revisions/9/download -O $(pwd)/boards/kubernetes_node_full.json
# wget https://grafana.com/api/dashboards/878/revisions/5/download -O $(pwd)/boards/elasticsearch.json
# wget https://grafana.com/api/dashboards/2292/revisions/5/download -O $(pwd)/boards/nginx_access_log.json



# MINE from: https://github.com/bossjones/bosslab-playbooks/blob/master/grafana-dashboards.md
wget https://grafana.com/api/dashboards/3305/revisions/1/download -O $(pwd)/boards/netdata_dashboard.json
wget https://grafana.com/api/dashboards/5526/revisions/1/download -O $(pwd)/boards/kubernetes_statefulset.json
wget https://grafana.com/api/dashboards/179/revisions/7/download -O $(pwd)/boards/docker_and_host_mintoring_w_prometheus.json
wget https://grafana.com/api/dashboards/8588/revisions/1/download -O $(pwd)/boards/kubernetes_deployment_statefulset_daemonset_metrics.json
wget https://grafana.com/api/dashboards/8919/revisions/7/download -O $(pwd)/boards/node_exporter_for_prometheus.json
wget https://grafana.com/api/dashboards/893/revisions/5/download -O $(pwd)/boards/docker_and_system_monitoring.json
wget https://grafana.com/api/dashboards/395/revisions/1/download -O $(pwd)/boards/docker_host_and_container_overview.json
wget https://grafana.com/api/dashboards/3522/revisions/1/download -O $(pwd)/boards/fluentd_dashboard.json
wget https://grafana.com/api/dashboards/1860/revisions/13/download -O $(pwd)/boards/node_exporter_full.json
wget https://grafana.com/api/dashboards/5984/revisions/1/download -O $(pwd)/boards/alerts_linux_nodes.json
wget https://grafana.com/api/dashboards/8715/revisions/1/download -O $(pwd)/boards/elasticsearch_logs_from_fluentd.json
wget https://grafana.com/api/dashboards/9450/revisions/1/download -O $(pwd)/boards/kubernetes_pods_dashboard.json
wget https://grafana.com/api/dashboards/9673/revisions/1/download -O $(pwd)/boards/kubeless.json
wget https://grafana.com/api/dashboards/9578/revisions/3/download -O $(pwd)/boards/alertmanager.json
wget https://grafana.com/api/dashboards/6336/revisions/1/download -O $(pwd)/boards/kubernetes_pods.json
wget https://grafana.com/api/dashboards/7107/revisions/1/download -O $(pwd)/boards/netdata.json
wget https://grafana.com/api/dashboards/8702/revisions/1/download -O $(pwd)/boards/stats_at_a_glance_for_home_infra.json
wget https://grafana.com/api/dashboards/1486/revisions/4/download -O $(pwd)/boards/unifi_ap_dashboard.json
wget https://grafana.com/api/dashboards/6885/revisions/1/download -O $(pwd)/boards/unifi_controller_dashboard.json
wget https://grafana.com/api/dashboards/3131/revisions/1/download -O $(pwd)/boards/kubernetes_all_nodes.json
wget https://grafana.com/api/dashboards/6879/revisions/1/download -O $(pwd)/boards/analysis_by_pod.json
wget https://grafana.com/api/dashboards/6873/revisions/2/download -O $(pwd)/boards/analysis_by_cluster.json
wget https://grafana.com/api/dashboards/6876/revisions/2/download -O $(pwd)/boards/analysis_by_namespace.json
wget https://grafana.com/api/dashboards/3831/revisions/1/download -O $(pwd)/boards/kubernetes_cluster_autoscaler.json

# WIP, prometheus render.
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/netdata_dashboard.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/kubernetes_statefulset.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/docker_and_host_mintoring_w_prometheus.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/kubernetes_deployment_statefulset_daemonset_metrics.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/node_exporter_for_prometheus.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/docker_and_system_monitoring.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/docker_host_and_container_overview.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/fluentd_dashboard.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/node_exporter_full.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/alerts_linux_nodes.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/elasticsearch_logs_from_fluentd.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/kubernetes_pods_dashboard.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/kubeless.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/alertmanager.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/kubernetes_pods.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/netdata.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/stats_at_a_glance_for_home_infra.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/unifi_ap_dashboard.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/unifi_controller_dashboard.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/kubernetes_all_nodes.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/analysis_by_pod.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/analysis_by_cluster.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/analysis_by_namespace.json
# gsed -i 's|\"datasource\":[^,]*|\"datasource\": \"\$datasource\"|g' $(pwd)/boards/kubernetes_cluster_autoscaler.json
