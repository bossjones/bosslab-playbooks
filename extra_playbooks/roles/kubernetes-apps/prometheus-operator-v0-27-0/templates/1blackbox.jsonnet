local service_monitor = import 'blackbox/service_monitor.libsonnet';
{
  'blackbox-podDisruptionBudget': import 'blackbox/pod_disruption_budget.libsonnet',
  'blackbox-service': import 'blackbox/service.libsonnet',
  'blackbox-configMap': import 'blackbox/config_map.libsonnet',
  'blackbox-serviceMonitor': service_monitor.get_service_monitor(name=''),
} + {
  ['blackbox-serviceMonitor' + monitor.name]:
    service_monitor.get_service_monitor(
      name=monitor.name,
      target=monitor.target,
      module=monitor.module,
    )
  for monitor in
    import 'blackbox/monitors.libsonnet'
}
