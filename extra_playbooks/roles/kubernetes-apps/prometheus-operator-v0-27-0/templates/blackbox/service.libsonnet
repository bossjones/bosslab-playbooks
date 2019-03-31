{
  apiVersion: 'v1',
  kind: 'Service',
  metadata: {
    labels: {
      'k8s-app': 'blackbox-exporter',
    },
    name: 'blackbox-exporter',
    namespace: 'monitoring',
  },
  spec: {
    clusterIP: 'None',
    ports: [
      {
        name: 'http-metrics',
        port: 9115,
        protocol: 'TCP',
      },
    ],
    selector: {
      app: 'blackbox-exporter',
    },
    type: 'ClusterIP',
  },
}
