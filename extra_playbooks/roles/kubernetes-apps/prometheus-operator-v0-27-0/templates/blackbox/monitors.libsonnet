[
  {
    name: 'alertmanager',
    target: 'http://alertmanager-main.monitoring.svc.cluster.local:9093/-/healthy',
    module: 'http_2xx',
  },
  {
    name: 'grafana',
    target: 'http://grafana.monitoring.svc.cluster.local:3000',
    module: 'http_2xx',
  },
  {
    name: 'prometheus-k8s',
    target: 'http://prometheus-k8s.monitoring.svc.cluster.local:9090/-/healthy',
    module: 'http_2xx',
  },
  {
    name: 'prometheus-adapter',
    target: 'https://kubernetes.default.svc/apis/custom.metrics.k8s.io/v1beta1',
    module: 'https_k8s_2xx',
  },
] + []
