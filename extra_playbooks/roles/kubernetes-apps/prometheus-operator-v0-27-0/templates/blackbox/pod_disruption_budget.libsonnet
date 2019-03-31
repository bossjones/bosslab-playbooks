{
  kind: 'PodDisruptionBudget',
  apiVersion: 'policy/v1beta1',
  metadata: {
    name: 'pdb-blackbox-exporter',
    namespace: 'monitoring',
  },
  spec: {
    minAvailable: 1,
    selector: {
      matchLabels: {
        app: 'blackbox-exporter',
      },
    },
  },
}
