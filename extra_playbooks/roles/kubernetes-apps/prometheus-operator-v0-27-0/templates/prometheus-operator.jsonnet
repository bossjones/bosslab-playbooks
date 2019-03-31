local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-kubeadm.libsonnet') +
  // Note that NodePort type services is likely not a good idea for your production use case, it is only used for demonstration purposes here.
  // (import 'kube-prometheus/kube-prometheus-node-ports.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet') +
  {
  _config+:: {
    namespace: 'monitoring',

    imageRepos+:: {
        prometheus: "quay.io/prometheus/prometheus",
        alertmanager: "quay.io/prometheus/alertmanager",
        kubeStateMetrics: "quay.io/coreos/kube-state-metrics",
        kubeRbacProxy: "quay.io/coreos/kube-rbac-proxy",
        addonResizer: "quay.io/coreos/addon-resizer",
        nodeExporter: "quay.io/prometheus/node-exporter",
        prometheusOperator: "quay.io/coreos/prometheus-operator",
    },

    // NOTE: We might need just this, instead of all of that extra stuff. See example in kubernetes-cluster-borg > example.jsonnet
    // prometheus+:: {
    //     namespaces+: ['echoserver', 'kube-public'],
    // },

    prometheus+:: {
        namespaces+: ['echoserver', 'kube-public'],
        serviceMonitorKubeControllerManager+:
        {
          spec+: {
            endpoints: [
              {
                port: 'http-metrics',
                interval: '30s',
                metricRelabelings: [
                  {
                    sourceLabels: ['__meta_kubernetes_pod_annotation_prometheus_io_scrape'],
                    regex: true,
                    action: 'keep',
                  },
                  {
                    sourceLabels: ['__meta_kubernetes_pod_annotation_prometheus_io_scheme'],
                    target_label: '__scheme__',
                    regex: '(https?)',
                    action: 'replace',
                  },
                ],
              },
            ],
            selector: {
              matchLabels: {
                'k8s-app': 'kube-controller-manager',
              },
            },
            namespaceSelector: {
              matchNames: [
                'kube-system',
              ],
            },
          },
        },
    },

    prometheusRules+:: {
      groups+: [
        {
          name: 'example-group',
          rules: [
            {
              record: 'some_recording_rule_name',
              expr: 'vector(1)',
            },
          ],
        },
      ],
    },

    grafana+:: {
      config: { // http://docs.grafana.org/installation/configuration/
        sections: {
          "auth.anonymous": {enabled: true},
        },
      },
    },

    alertmanager+:: {
      name: 'main',
      config: |||
        global:
          resolve_timeout: 5m
        route:
          group_by: ['job']
          group_wait: 30s
          group_interval: 5m
          repeat_interval: 12h
          receiver: 'null'
          routes:
          - match:
              alertname: DeadMansSwitch
            receiver: 'null'
        receivers:
        - name: 'null'
      |||,
      replicas: 3,
    },

    kubeStateMetrics+:: {
      collectors: '',  // empty string gets a default set
      scrapeInterval: '30s',
      scrapeTimeout: '30s',

      baseCPU: '100m',
      baseMemory: '150Mi',
      cpuPerNode: '2m',
      memoryPerNode: '30Mi',
    },
  },

  // SOURCE: k8s-infrastructure
  kubePrometheus+: {
    namespace+: {
      metadata+: {
        labels+: {
          name+: 'monitoring',
        },
      },
    },
  },
};

{ ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) }
