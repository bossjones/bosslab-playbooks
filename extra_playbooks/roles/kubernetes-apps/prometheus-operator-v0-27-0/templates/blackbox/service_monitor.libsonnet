{
  //get_default_endpoints Returns a default endpoint for blackbox exporter to check default blackbox metrics
  local get_default_endpoints() = [{
    interval: '60s',
    port: 'http-metrics',
  }],

  //get_endpoints Returns an endpoint that checks the specified target
  local get_endpoints(name, target, module, interval='60s') =
    if name == '' then error 'Invalid empty name'
    else
      if target == '' then error 'Invalid empty target'
      else [{
        interval: '60s',
        params: {
          module: [module],
          target: [target],
        },
        path: '/probe',
        targetPort: 9115,
        metricRelabelings: [
          {
            targetLabel: 'name',
            replacement: name,
          },
          {
            targetLabel: 'target',
            replacement: target,
          },
        ],
      }],

  get_service_monitor(name='', target='', module=''):: {
    apiVersion: 'monitoring.coreos.com/v1',
    kind: 'ServiceMonitor',
    metadata: {
      labels: {
        'k8s-app': 'blackbox-exporter',
      },
      namespace: 'monitoring',
      name: 'blackbox-exporter' + if name == '' then '' else '-' + name,
    },
    spec: {
      endpoints: if name == '' then
        get_default_endpoints()
      else
        get_endpoints(name, target, module),
      jobLabel: 'k8s-app',
      namespaceSelector: {
        matchNames: [
          'monitoring',
        ],
      },
      selector: {
        app: 'blackbox-exporter',
      },
    },
  },
}
